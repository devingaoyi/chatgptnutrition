const content = document.querySelector("#content");
const searchForm = document.querySelector("#searchForm");
const searchInput = document.querySelector("#searchInput");
const shareButton = document.querySelector("#shareButton");
const toast = document.querySelector("#toast");

const labels = {
  evidence: {
    high: "高",
    medium: "中",
    low: "低",
    unsupported: "不支持",
  },
  feasibility: {
    high: "高",
    medium: "中",
    low: "低",
  },
  risk: {
    low: "低",
    medium: "中",
    high: "高",
  },
  studyType: {
    meta_analysis: "Meta 分析",
    systematic_review: "系统综述",
    rct: "随机对照试验",
    observational: "观察性研究",
    guideline: "指南/共识",
    mechanism: "机制研究",
    official_fact_sheet: "官方资料",
    clinical_trial_registry: "临床试验注册",
    other: "其他",
  },
};

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function setLoading(text = "正在查询") {
  content.innerHTML = `<div class="loading">${escapeHtml(text)}</div>`;
}

function setError(message) {
  content.innerHTML = `<div class="error">${escapeHtml(message)}</div>`;
}

function showToast(message) {
  toast.textContent = message;
  toast.classList.add("show");
  window.setTimeout(() => toast.classList.remove("show"), 1800);
}

async function fetchJson(url, options) {
  const response = await fetch(url, options);
  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(data?.error?.message || `请求失败：${response.status}`);
  }
  return data;
}

function updateUrl(params) {
  const url = new URL(window.location.href);
  url.search = "";
  Object.entries(params).forEach(([key, value]) => {
    if (value) {
      url.searchParams.set(key, value);
    }
  });
  window.history.replaceState({}, "", url.toString());
}

function scoreClass(kind, value) {
  if (kind === "risk") {
    return value === "high" ? "high-risk" : value === "low" ? "low-risk" : "medium";
  }
  return value || "medium";
}

function formatRange(min, max, unit) {
  if (!min && !max) {
    return unit || "需按研究场景判断";
  }
  const clean = (value) => Number(value).toString();
  if (min && max && clean(min) !== clean(max)) {
    return `${clean(min)}-${clean(max)} ${unit || ""}`.trim();
  }
  return `${clean(min || max)} ${unit || ""}`.trim();
}

function formatDuration(min, max, unit) {
  if (!min && !max) {
    return "未结构化";
  }
  const unitMap = { day: "天", week: "周", month: "月" };
  const label = unitMap[unit] || unit || "";
  if (min && max && min !== max) {
    return `${min}-${max}${label}`;
  }
  return `${min || max}${label}`;
}

function renderClaimCard(claim) {
  return `
    <article class="claim-card">
      <div class="claim-top">
        <div class="claim-title">
          <h3>${escapeHtml(claim.title)}</h3>
          <p>${escapeHtml(claim.public_conclusion)}</p>
        </div>
        <span class="tag">${escapeHtml(claim.status === "draft" ? "草稿" : "已发布")}</span>
      </div>

      <div class="score-row">
        <div class="score ${scoreClass("evidence", claim.evidence_strength)}">
          <b>证据强度</b>
          <span>${labels.evidence[claim.evidence_strength] || claim.evidence_strength}</span>
        </div>
        <div class="score ${scoreClass("feasibility", claim.feasibility)}">
          <b>实际可行性</b>
          <span>${labels.feasibility[claim.feasibility] || claim.feasibility}</span>
        </div>
        <div class="score ${scoreClass("risk", claim.safety_risk)}">
          <b>安全风险</b>
          <span>${labels.risk[claim.safety_risk] || claim.safety_risk}</span>
        </div>
      </div>

      <div class="meta-grid">
        <div class="meta-item">
          <b>研究剂量范围</b>
          <span>${escapeHtml(formatRange(claim.dose_min, claim.dose_max, claim.dose_unit))}</span>
        </div>
        <div class="meta-item">
          <b>研究周期</b>
          <span>${escapeHtml(formatDuration(claim.duration_min, claim.duration_max, claim.duration_unit))}</span>
        </div>
        <div class="meta-item">
          <b>更适合</b>
          <span>${escapeHtml(claim.applicability || claim.population || "需结合人群判断")}</span>
        </div>
        <div class="meta-item">
          <b>慎用/不适用</b>
          <span>${escapeHtml(claim.cautions || "未结构化")}</span>
        </div>
      </div>

      <div class="toolbar">
        <button type="button" data-claim="${escapeHtml(claim.id)}">查看专业证据</button>
      </div>
    </article>
  `;
}

function renderReportHeader(title, subtitle, shareParams) {
  return `
    <div class="section-head">
      <div>
        <h2>${escapeHtml(title)}</h2>
        <p>${escapeHtml(subtitle)}</p>
      </div>
      <button class="icon-button" type="button" data-share='${escapeHtml(JSON.stringify(shareParams))}' title="复制当前报告链接" aria-label="复制当前报告链接">
        <span aria-hidden="true">↗</span>
      </button>
    </div>
  `;
}

function renderIngredientReport(data) {
  const claims = data.claims.map(renderClaimCard).join("");
  content.innerHTML = `
    ${renderReportHeader(
      data.ingredient.name_cn,
      `${data.ingredient.category} · ${data.ingredient.summary || ""}`,
      { ingredient: data.ingredient.slug },
    )}
    <div class="claim-list">${claims || "<div class='loading'>暂无可展示结论</div>"}</div>
  `;
}

function renderTargetReport(data) {
  const claims = data.claims.map(renderClaimCard).join("");
  content.innerHTML = `
    ${renderReportHeader(
      data.healthTarget.name,
      `${data.healthTarget.compliant_name} · ${data.healthTarget.description || ""}`,
      { target: data.healthTarget.slug },
    )}
    <div class="claim-list">${claims || "<div class='loading'>暂无可展示结论</div>"}</div>
  `;
}

function renderSearchResults(data) {
  const ingredientCards = data.ingredients
    .map(
      (item) => `
        <button class="result-card" type="button" data-ingredient="${escapeHtml(item.slug)}">
          <strong>${escapeHtml(item.name_cn)}</strong>
          <span>${escapeHtml(item.name_en || item.category)} · 匹配：${escapeHtml(item.matched_term)}</span>
        </button>
      `,
    )
    .join("");
  const targetCards = data.healthTargets
    .map(
      (item) => `
        <button class="result-card" type="button" data-target="${escapeHtml(item.slug)}">
          <strong>${escapeHtml(item.name)}</strong>
          <span>${escapeHtml(item.compliant_name)} · 匹配：${escapeHtml(item.matched_term)}</span>
        </button>
      `,
    )
    .join("");
  const productCards = data.products
    .map(
      (item) => `
        <button class="result-card" type="button" disabled>
          <strong>${escapeHtml(item.name)}</strong>
          <span>${escapeHtml(item.brand || "未知品牌")} · 商品标签尚未解析</span>
        </button>
      `,
    )
    .join("");
  const hasResults = ingredientCards || targetCards || productCards;

  content.innerHTML = `
    <div class="section-head">
      <div>
        <h2>查询结果</h2>
        <p>${escapeHtml(data.query)}</p>
      </div>
    </div>
    ${
      hasResults
        ? `<div class="result-grid">${ingredientCards}${targetCards}${productCards}</div>`
        : `<div class="empty-state"><h2>未找到匹配项</h2><p>当前体验版优先支持成分和健康方向，商品名需要先录入标签信息。</p></div>`
    }
  `;
}

function evidenceRow(label, value) {
  return `
    <div class="evidence-row">
      <b>${escapeHtml(label)}</b>
      <span>${escapeHtml(value || "未结构化")}</span>
    </div>
  `;
}

function renderLiteratureList(literatures) {
  if (!literatures.length) {
    return `
      <div class="empty-evidence">
        暂无已审核文献关联。当前只显示结构化结论字段；该条目正式发布前仍需要完成文献提取和专家复核。
      </div>
    `;
  }

  return literatures
    .map((item) => {
      const meta = [
        labels.studyType[item.study_type] || item.study_type,
        item.journal,
        item.year,
        item.evidence_role ? `角色：${item.evidence_role}` : "",
      ]
        .filter(Boolean)
        .join(" · ");
      return `
        <article class="literature-item">
          <h4>${escapeHtml(item.title)}</h4>
          <p>${escapeHtml(meta)}</p>
          ${
            item.extracted_result
              ? `<div class="literature-result">${escapeHtml(item.extracted_result)}</div>`
              : ""
          }
          ${
            item.url
              ? `<a href="${escapeHtml(item.url)}" target="_blank" rel="noreferrer">打开文献链接</a>`
              : ""
          }
        </article>
      `;
    })
    .join("");
}

function closeEvidenceModal() {
  document.querySelector(".modal-backdrop")?.remove();
  document.body.classList.remove("modal-open");
}

function openEvidenceModal(data) {
  closeEvidenceModal();
  const claim = data.claim;
  const modal = document.createElement("div");
  modal.className = "modal-backdrop";
  modal.innerHTML = `
    <section class="evidence-modal" role="dialog" aria-modal="true" aria-labelledby="evidenceModalTitle">
      <header class="modal-head">
        <div>
          <h2 id="evidenceModalTitle">${escapeHtml(claim.title)}</h2>
          <p>${escapeHtml(claim.ingredient_name_cn)} · ${escapeHtml(claim.health_target_compliant_name)}</p>
        </div>
        <button type="button" class="icon-button" data-modal-close aria-label="关闭">×</button>
      </header>

      <div class="modal-body">
        <section>
          <h3>专业结构化摘要</h3>
          <div class="evidence-table">
            ${evidenceRow("人群", claim.population)}
            ${evidenceRow("终点指标", claim.outcome_metric)}
            ${evidenceRow("研究剂量", formatRange(claim.dose_min, claim.dose_max, claim.dose_unit))}
            ${evidenceRow("研究周期", formatDuration(claim.duration_min, claim.duration_max, claim.duration_unit))}
            ${evidenceRow("剂量说明", claim.dose_note)}
            ${evidenceRow("适用条件", claim.applicability)}
            ${evidenceRow("慎用人群", claim.cautions)}
            ${evidenceRow("合规限制", claim.compliance_note)}
          </div>
        </section>

        <section>
          <h3>关联文献</h3>
          <div class="literature-list">
            ${renderLiteratureList(data.literatures)}
          </div>
        </section>
      </div>
    </section>
  `;
  document.body.appendChild(modal);
  document.body.classList.add("modal-open");
}

async function loadIngredient(slug) {
  setLoading("正在读取成分报告");
  const data = await fetchJson(`/api/reports/ingredients/${encodeURIComponent(slug)}`);
  renderIngredientReport(data);
  updateUrl({ ingredient: slug });
}

async function loadTarget(slug) {
  setLoading("正在读取健康方向报告");
  const data = await fetchJson(`/api/reports/health-targets/${encodeURIComponent(slug)}`);
  renderTargetReport(data);
  updateUrl({ target: slug });
}

async function search(q) {
  const query = q.trim();
  if (!query) {
    searchInput.focus();
    return;
  }
  setLoading("正在搜索");
  const data = await fetchJson(`/api/search?q=${encodeURIComponent(query)}`);
  renderSearchResults(data);
  updateUrl({ q: query });
}

async function showClaimEvidence(id) {
  const data = await fetchJson(`/api/evidence-claims/${encodeURIComponent(id)}`);
  openEvidenceModal(data);
}

async function copyShare(params) {
  const url = new URL(window.location.href);
  url.search = "";
  Object.entries(params || Object.fromEntries(new URLSearchParams(window.location.search))).forEach(
    ([key, value]) => {
      if (value) {
        url.searchParams.set(key, value);
      }
    },
  );
  await navigator.clipboard.writeText(url.toString());
  showToast("分享链接已复制");
}

searchForm.addEventListener("submit", (event) => {
  event.preventDefault();
  search(searchInput.value).catch((error) => setError(error.message));
});

document.addEventListener("click", (event) => {
  const button = event.target.closest("button");
  const backdrop = event.target.classList?.contains("modal-backdrop");

  if (backdrop || button?.hasAttribute("data-modal-close")) {
    closeEvidenceModal();
    return;
  }
  if (!button) {
    return;
  }

  const ingredient = button.dataset.ingredient;
  const target = button.dataset.target;
  const claim = button.dataset.claim;
  const share = button.dataset.share;

  if (ingredient) {
    loadIngredient(ingredient).catch((error) => setError(error.message));
  }
  if (target) {
    loadTarget(target).catch((error) => setError(error.message));
  }
  if (claim) {
    showClaimEvidence(claim).catch((error) => showToast(error.message));
  }
  if (share) {
    copyShare(JSON.parse(share)).catch(() => showToast("复制失败"));
  }
});

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    closeEvidenceModal();
  }
});

shareButton.addEventListener("click", () => {
  copyShare().catch(() => showToast("复制失败"));
});

async function boot() {
  const params = new URLSearchParams(window.location.search);
  const ingredient = params.get("ingredient");
  const target = params.get("target");
  const q = params.get("q");

  try {
    if (ingredient) {
      await loadIngredient(ingredient);
    } else if (target) {
      await loadTarget(target);
    } else if (q) {
      searchInput.value = q;
      await search(q);
    }
  } catch (error) {
    setError(error.message);
  }
}

boot();
