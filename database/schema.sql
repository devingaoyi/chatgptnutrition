CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$ BEGIN CREATE TYPE user_role AS ENUM ('consumer', 'expert', 'admin'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE user_status AS ENUM ('active', 'disabled'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE record_status AS ENUM ('active', 'hidden'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE risk_level AS ENUM ('low', 'medium', 'high'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE evidence_strength AS ENUM ('high', 'medium', 'low', 'unsupported'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE feasibility_level AS ENUM ('high', 'medium', 'low'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE claim_status AS ENUM ('draft', 'pending_review', 'published', 'needs_review', 'withdrawn'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE study_type AS ENUM ('meta_analysis', 'systematic_review', 'rct', 'observational', 'guideline', 'mechanism', 'official_fact_sheet', 'clinical_trial_registry', 'other'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE evidence_role AS ENUM ('primary', 'supporting', 'conflicting', 'safety'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE product_status AS ENUM ('draft', 'verified', 'hidden'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE order_status AS ENUM ('pending', 'paid', 'cancelled', 'refunded', 'failed'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE entitlement_source AS ENUM ('purchase', 'coupon', 'admin_grant'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE coupon_type AS ENUM ('query_credit', 'amount_off', 'percent_off'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE coupon_status AS ENUM ('active', 'paused', 'expired', 'disabled'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE share_resource_type AS ENUM ('ingredient', 'health_target', 'evidence_claim', 'product'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE import_job_status AS ENUM ('pending', 'running', 'succeeded', 'failed'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
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

CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  openid varchar(128) UNIQUE,
  phone_hash varchar(128),
  nickname varchar(128),
  role user_role NOT NULL DEFAULT 'consumer',
  status user_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ingredients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug varchar(128) NOT NULL UNIQUE,
  name_cn varchar(128) NOT NULL,
  name_en varchar(128),
  category varchar(64) NOT NULL,
  common_forms jsonb NOT NULL DEFAULT '[]'::jsonb,
  summary text,
  safety_note text,
  status record_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ingredient_aliases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ingredient_id uuid NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
  alias varchar(128) NOT NULL,
  language varchar(16) NOT NULL DEFAULT 'zh',
  source varchar(32) NOT NULL DEFAULT 'manual',
  priority integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS health_targets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug varchar(128) NOT NULL UNIQUE,
  name varchar(128) NOT NULL,
  compliant_name varchar(128) NOT NULL,
  description text,
  risk_level risk_level NOT NULL DEFAULT 'medium',
  status record_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS health_target_aliases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  health_target_id uuid NOT NULL REFERENCES health_targets(id) ON DELETE CASCADE,
  alias varchar(128) NOT NULL,
  display_rewrite varchar(128) NOT NULL,
  is_sensitive boolean NOT NULL DEFAULT false,
  blocked_term boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS evidence_claims (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ingredient_id uuid NOT NULL REFERENCES ingredients(id) ON DELETE RESTRICT,
  health_target_id uuid NOT NULL REFERENCES health_targets(id) ON DELETE RESTRICT,
  title varchar(256) NOT NULL,
  population text,
  outcome_metric varchar(256),
  evidence_strength evidence_strength NOT NULL,
  feasibility feasibility_level NOT NULL,
  safety_risk risk_level NOT NULL,
  public_conclusion text NOT NULL,
  professional_conclusion text,
  dose_min numeric(12,4),
  dose_max numeric(12,4),
  dose_unit varchar(32),
  dose_note text,
  duration_min integer,
  duration_max integer,
  duration_unit varchar(32),
  effect_size_summary text,
  applicability text,
  cautions text,
  common_misunderstanding text,
  compliance_note text,
  status claim_status NOT NULL DEFAULT 'draft',
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  reviewed_by uuid REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at timestamptz,
  next_review_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (ingredient_id, health_target_id, title),
  CHECK (dose_min IS NULL OR dose_max IS NULL OR dose_min <= dose_max),
  CHECK (duration_min IS NULL OR duration_max IS NULL OR duration_min <= duration_max)
);

CREATE TABLE IF NOT EXISTS literatures (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  year integer,
  journal varchar(256),
  study_type study_type NOT NULL DEFAULT 'other',
  pmid varchar(32),
  doi varchar(256),
  url text,
  abstract text,
  population text,
  sample_size integer CHECK (sample_size IS NULL OR sample_size >= 0),
  intervention text,
  comparator text,
  outcomes text,
  limitations text,
  source varchar(64) NOT NULL DEFAULT 'manual',
  imported_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS evidence_claim_literatures (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  evidence_claim_id uuid NOT NULL REFERENCES evidence_claims(id) ON DELETE CASCADE,
  literature_id uuid NOT NULL REFERENCES literatures(id) ON DELETE CASCADE,
  evidence_role evidence_role NOT NULL DEFAULT 'supporting',
  weight integer NOT NULL DEFAULT 3 CHECK (weight BETWEEN 1 AND 5),
  extracted_dose varchar(128),
  extracted_duration varchar(128),
  extracted_result text,
  reviewer_note text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (evidence_claim_id, literature_id, evidence_role)
);

CREATE TABLE IF NOT EXISTS literature_import_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ingredient_id uuid REFERENCES ingredients(id) ON DELETE SET NULL,
  health_target_id uuid REFERENCES health_targets(id) ON DELETE SET NULL,
  source varchar(64) NOT NULL,
  query text NOT NULL,
  status import_job_status NOT NULL DEFAULT 'pending',
  result_count integer NOT NULL DEFAULT 0 CHECK (result_count >= 0),
  error_message text,
  created_by uuid REFERENCES users(id) ON DELETE SET NULL,
  started_at timestamptz,
  finished_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

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

CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  brand varchar(128),
  name varchar(256) NOT NULL,
  normalized_name varchar(256) NOT NULL,
  product_type varchar(64),
  label_source varchar(128),
  label_verified boolean NOT NULL DEFAULT false,
  source_url text,
  status product_status NOT NULL DEFAULT 'draft',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS product_ingredients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  ingredient_id uuid NOT NULL REFERENCES ingredients(id) ON DELETE RESTRICT,
  amount_per_serving numeric(12,4),
  unit varchar(32),
  suggested_servings_per_day numeric(8,4),
  calculated_daily_amount numeric(12,4),
  form varchar(128),
  note text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (product_id, ingredient_id, form)
);

CREATE TABLE IF NOT EXISTS query_orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  order_no varchar(64) NOT NULL UNIQUE,
  amount_cents integer NOT NULL CHECK (amount_cents >= 0),
  currency varchar(8) NOT NULL DEFAULT 'CNY',
  entitlement_count integer NOT NULL CHECK (entitlement_count > 0),
  status order_status NOT NULL DEFAULT 'pending',
  payment_provider varchar(32),
  provider_trade_no varchar(128),
  paid_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS query_entitlements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  total_count integer NOT NULL CHECK (total_count > 0),
  used_count integer NOT NULL DEFAULT 0 CHECK (used_count >= 0),
  source entitlement_source NOT NULL,
  source_ref_type varchar(64),
  source_ref_id uuid,
  expires_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (used_count <= total_count)
);

CREATE TABLE IF NOT EXISTS coupons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code varchar(64) NOT NULL UNIQUE,
  name varchar(128) NOT NULL,
  coupon_type coupon_type NOT NULL DEFAULT 'query_credit',
  query_count integer CHECK (query_count IS NULL OR query_count > 0),
  amount_off_cents integer CHECK (amount_off_cents IS NULL OR amount_off_cents >= 0),
  percent_off numeric(5,2) CHECK (percent_off IS NULL OR (percent_off > 0 AND percent_off <= 100)),
  max_redemptions integer CHECK (max_redemptions IS NULL OR max_redemptions > 0),
  per_user_limit integer NOT NULL DEFAULT 1 CHECK (per_user_limit > 0),
  starts_at timestamptz,
  expires_at timestamptz,
  status coupon_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS coupon_redemptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id uuid NOT NULL REFERENCES coupons(id) ON DELETE RESTRICT,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  entitlement_id uuid REFERENCES query_entitlements(id) ON DELETE SET NULL,
  snapshot_code varchar(64) NOT NULL,
  redeemed_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS share_links (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token varchar(96) NOT NULL UNIQUE,
  creator_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  resource_type share_resource_type NOT NULL,
  resource_id uuid NOT NULL,
  title varchar(256),
  summary text,
  is_public boolean NOT NULL DEFAULT true,
  expires_at timestamptz,
  last_accessed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS query_consumptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  entitlement_id uuid NOT NULL REFERENCES query_entitlements(id) ON DELETE RESTRICT,
  evidence_claim_id uuid REFERENCES evidence_claims(id) ON DELETE SET NULL,
  query_input text NOT NULL,
  share_link_id uuid REFERENCES share_links(id) ON DELETE SET NULL,
  consumed_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type varchar(64) NOT NULL,
  entity_id uuid NOT NULL,
  action varchar(64) NOT NULL,
  before_data jsonb,
  after_data jsonb,
  operator_id uuid REFERENCES users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_users_openid ON users(openid);
CREATE INDEX IF NOT EXISTS idx_ingredients_name_cn ON ingredients(name_cn);
CREATE INDEX IF NOT EXISTS idx_ingredients_name_en ON ingredients(name_en);
CREATE UNIQUE INDEX IF NOT EXISTS idx_ingredient_aliases_unique ON ingredient_aliases(ingredient_id, lower(alias));
CREATE INDEX IF NOT EXISTS idx_ingredient_aliases_alias ON ingredient_aliases(lower(alias));
CREATE INDEX IF NOT EXISTS idx_health_targets_name ON health_targets(name);
CREATE UNIQUE INDEX IF NOT EXISTS idx_health_target_aliases_unique ON health_target_aliases(health_target_id, lower(alias));
CREATE INDEX IF NOT EXISTS idx_health_target_aliases_alias ON health_target_aliases(lower(alias));
CREATE INDEX IF NOT EXISTS idx_evidence_claims_pair ON evidence_claims(ingredient_id, health_target_id);
CREATE INDEX IF NOT EXISTS idx_evidence_claims_status ON evidence_claims(status);
CREATE INDEX IF NOT EXISTS idx_evidence_claims_strength ON evidence_claims(evidence_strength);
CREATE UNIQUE INDEX IF NOT EXISTS idx_literatures_pmid_unique ON literatures(pmid) WHERE pmid IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_literatures_doi_unique ON literatures(lower(doi)) WHERE doi IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_literatures_study_type ON literatures(study_type);
CREATE INDEX IF NOT EXISTS idx_literature_import_jobs_status ON literature_import_jobs(status);
CREATE INDEX IF NOT EXISTS idx_literature_import_results_job ON literature_import_results(import_job_id);
CREATE INDEX IF NOT EXISTS idx_literature_import_results_status ON literature_import_results(screening_status);
CREATE INDEX IF NOT EXISTS idx_literature_import_results_external ON literature_import_results(external_source, external_id);
CREATE INDEX IF NOT EXISTS idx_literature_extractions_literature ON literature_extractions(literature_id);
CREATE INDEX IF NOT EXISTS idx_literature_extractions_pair ON literature_extractions(ingredient_id, health_target_id);
CREATE INDEX IF NOT EXISTS idx_literature_extractions_status ON literature_extractions(status);
CREATE INDEX IF NOT EXISTS idx_products_normalized_name ON products(lower(normalized_name));
CREATE INDEX IF NOT EXISTS idx_product_ingredients_product ON product_ingredients(product_id);
CREATE INDEX IF NOT EXISTS idx_query_orders_user ON query_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_query_entitlements_user ON query_entitlements(user_id);
CREATE INDEX IF NOT EXISTS idx_coupons_code ON coupons(code);
CREATE INDEX IF NOT EXISTS idx_coupon_redemptions_user ON coupon_redemptions(user_id);
CREATE INDEX IF NOT EXISTS idx_share_links_token ON share_links(token);
CREATE INDEX IF NOT EXISTS idx_query_consumptions_user ON query_consumptions(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON audit_logs(entity_type, entity_id);

DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_ingredients_updated_at ON ingredients;
CREATE TRIGGER trg_ingredients_updated_at BEFORE UPDATE ON ingredients FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_health_targets_updated_at ON health_targets;
CREATE TRIGGER trg_health_targets_updated_at BEFORE UPDATE ON health_targets FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_evidence_claims_updated_at ON evidence_claims;
CREATE TRIGGER trg_evidence_claims_updated_at BEFORE UPDATE ON evidence_claims FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_literatures_updated_at ON literatures;
CREATE TRIGGER trg_literatures_updated_at BEFORE UPDATE ON literatures FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_literature_import_jobs_updated_at ON literature_import_jobs;
CREATE TRIGGER trg_literature_import_jobs_updated_at BEFORE UPDATE ON literature_import_jobs FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_literature_import_results_updated_at ON literature_import_results;
CREATE TRIGGER trg_literature_import_results_updated_at BEFORE UPDATE ON literature_import_results FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_literature_extractions_updated_at ON literature_extractions;
CREATE TRIGGER trg_literature_extractions_updated_at BEFORE UPDATE ON literature_extractions FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_products_updated_at ON products;
CREATE TRIGGER trg_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_product_ingredients_updated_at ON product_ingredients;
CREATE TRIGGER trg_product_ingredients_updated_at BEFORE UPDATE ON product_ingredients FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_query_orders_updated_at ON query_orders;
CREATE TRIGGER trg_query_orders_updated_at BEFORE UPDATE ON query_orders FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_query_entitlements_updated_at ON query_entitlements;
CREATE TRIGGER trg_query_entitlements_updated_at BEFORE UPDATE ON query_entitlements FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_coupons_updated_at ON coupons;
CREATE TRIGGER trg_coupons_updated_at BEFORE UPDATE ON coupons FOR EACH ROW EXECUTE FUNCTION set_updated_at();
