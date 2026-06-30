DO $$ BEGIN CREATE TYPE screening_status AS ENUM ('unreviewed', 'included', 'excluded', 'duplicate', 'needs_full_text', 'needs_expert_review'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE extraction_status AS ENUM ('draft', 'needs_review', 'accepted', 'rejected'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE result_direction AS ENUM ('beneficial', 'neutral', 'harmful', 'mixed', 'unclear'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS literature_import_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  import_job_id uuid NOT NULL REFERENCES literature_import_jobs(id) ON DELETE CASCADE,
  literature_id uuid REFERENCES literatures(id) ON DELETE SET NULL,
  external_source varchar(64) NOT NULL,
  external_id varchar(128) NOT NULL,
  candidate_score numeric(6,2) NOT NULL DEFAULT 0,
  screening_status screening_status NOT NULL DEFAULT 'unreviewed',
  screening_reason text,
  raw_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (import_job_id, external_source, external_id)
);

CREATE TABLE IF NOT EXISTS literature_extractions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  literature_id uuid NOT NULL REFERENCES literatures(id) ON DELETE CASCADE,
  ingredient_id uuid REFERENCES ingredients(id) ON DELETE SET NULL,
  health_target_id uuid REFERENCES health_targets(id) ON DELETE SET NULL,
  population text,
  intervention text,
  dose_text varchar(256),
  duration_text varchar(256),
  comparator text,
  outcomes text,
  result_direction result_direction NOT NULL DEFAULT 'unclear',
  effect_text text,
  adverse_events text,
  limitations text,
  risk_of_bias varchar(64),
  extraction_note text,
  extracted_by uuid REFERENCES users(id) ON DELETE SET NULL,
  reviewed_by uuid REFERENCES users(id) ON DELETE SET NULL,
  status extraction_status NOT NULL DEFAULT 'draft',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_literature_import_results_job ON literature_import_results(import_job_id);
CREATE INDEX IF NOT EXISTS idx_literature_import_results_status ON literature_import_results(screening_status);
CREATE INDEX IF NOT EXISTS idx_literature_import_results_external ON literature_import_results(external_source, external_id);
CREATE INDEX IF NOT EXISTS idx_literature_extractions_literature ON literature_extractions(literature_id);
CREATE INDEX IF NOT EXISTS idx_literature_extractions_pair ON literature_extractions(ingredient_id, health_target_id);
CREATE INDEX IF NOT EXISTS idx_literature_extractions_status ON literature_extractions(status);

DROP TRIGGER IF EXISTS trg_literature_import_results_updated_at ON literature_import_results;
CREATE TRIGGER trg_literature_import_results_updated_at BEFORE UPDATE ON literature_import_results FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_literature_extractions_updated_at ON literature_extractions;
CREATE TRIGGER trg_literature_extractions_updated_at BEFORE UPDATE ON literature_extractions FOR EACH ROW EXECUTE FUNCTION set_updated_at();
