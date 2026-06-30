import json
from pathlib import Path

import streamlit as st


DATA_PATH = Path(__file__).parent / "data" / "demo_data.json"

EVIDENCE_LABELS = {
    "high": "高",
    "medium": "中",
    "low": "低",
    "unsupported": "不支持",
}

FEASIBILITY_LABELS = {
    "high": "高",
    "medium": "中",
    "low": "低",
}

RISK_LABELS = {
    "low": "低",
    "medium": "中",
    "high": "高",
}

STUDY_TYPE_LABELS = {
    "meta_analysis": "Meta 分析",
    "systematic_review": "系统综述",
    "rct": "随机对照试验",
    "observational": "观察性研究",
    "guideline": "指南/共识",
    "mechanism": "机制研究",
    "official_fact_sheet": "官方资料",
    "clinical_trial_registry": "临床试验注册",
    "other": "其他",
}


@st.cache_data
def load_data():
    with DATA_PATH.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

    ingredients_by_slug = {item["slug"]: item for item in data["ingredients"]}
    targets_by_slug = {item["slug"]: item for item in data["health_targets"]}
    claims_by_ingredient = {}
    claims_by_target = {}

    for claim in data["claims"]:
        claims_by_ingredient.setdefault(claim["ingredient_slug"], []).append(claim)
        claims_by_target.setdefault(claim["health_target_slug"], []).append(claim)

    return data, ingredients_by_slug, targets_by_slug, claims_by_ingredient, claims_by_target


def format_range(min_value, max_value, unit):
    if min_value is None and max_value is None:
        return unit or "需按研究场景判断"
    if min_value is not None and max_value is not None and str(float(min_value)) != str(float(max_value)):
        return f"{float(min_value):g}-{float(max_value):g} {unit or ''}".strip()
    value = min_value if min_value is not None else max_value
    return f"{float(value):g} {unit or ''}".strip()


def format_duration(min_value, max_value, unit):
    if min_value is None and max_value is None:
        return "未结构化"
    unit_label = {"day": "天", "week": "周", "month": "月"}.get(unit, unit or "")
    if min_value is not None and max_value is not None and min_value != max_value:
        return f"{min_value}-{max_value}{unit_label}"
    return f"{min_value or max_value}{unit_label}"


def score_badge(label, value, mapping):
    st.metric(label, mapping.get(value, value or "未结构化"))


def claim_sort_key(claim):
    evidence_order = {"high": 0, "medium": 1, "low": 2, "unsupported": 3}
    risk_order = {"low": 0, "medium": 1, "high": 2}
    return (
        evidence_order.get(claim.get("evidence_strength"), 9),
        risk_order.get(claim.get("safety_risk"), 9),
        claim.get("title", ""),
    )


def render_literature(literature):
    with st.container(border=True):
        st.markdown(f"**{literature.get('title', '未命名文献')}**")
        meta = [
            STUDY_TYPE_LABELS.get(literature.get("study_type"), literature.get("study_type")),
            literature.get("journal"),
            str(literature.get("year")) if literature.get("year") else None,
            f"角色：{literature.get('evidence_role')}" if literature.get("evidence_role") else None,
        ]
        st.caption(" · ".join([item for item in meta if item]))
        if literature.get("extracted_result"):
            st.write(literature["extracted_result"])
        if literature.get("limitations"):
            st.caption(f"局限性：{literature['limitations']}")
        if literature.get("url"):
            st.link_button("打开文献链接", literature["url"])


def render_claim(claim):
    with st.container(border=True):
        left, right = st.columns([0.78, 0.22])
        with left:
            st.subheader(claim["title"])
            st.write(claim["public_conclusion"])
        with right:
            st.caption("状态")
            st.markdown("**草稿**" if claim.get("status") == "draft" else "**已发布**")

        col1, col2, col3 = st.columns(3)
        with col1:
            score_badge("证据强度", claim.get("evidence_strength"), EVIDENCE_LABELS)
        with col2:
            score_badge("实际可行性", claim.get("feasibility"), FEASIBILITY_LABELS)
        with col3:
            score_badge("安全风险", claim.get("safety_risk"), RISK_LABELS)

        meta1, meta2 = st.columns(2)
        with meta1:
            st.markdown("**研究剂量范围**")
            st.write(format_range(claim.get("dose_min"), claim.get("dose_max"), claim.get("dose_unit")))
            st.markdown("**更适合**")
            st.write(claim.get("applicability") or claim.get("population") or "需结合人群判断")
        with meta2:
            st.markdown("**研究周期**")
            st.write(format_duration(claim.get("duration_min"), claim.get("duration_max"), claim.get("duration_unit")))
            st.markdown("**慎用/不适用**")
            st.write(claim.get("cautions") or "未结构化")

        with st.expander("查看专业证据", expanded=False):
            st.markdown("#### 专业结构化摘要")
            st.write(f"**人群：** {claim.get('population') or '未结构化'}")
            st.write(f"**终点指标：** {claim.get('outcome_metric') or '未结构化'}")
            st.write(f"**剂量说明：** {claim.get('dose_note') or '未结构化'}")
            st.write(f"**合规限制：** {claim.get('compliance_note') or '未结构化'}")
            if claim.get("professional_conclusion"):
                st.write(f"**专业结论：** {claim['professional_conclusion']}")

            st.markdown("#### 关联文献")
            literatures = claim.get("literatures", [])
            if not literatures:
                st.info("暂无已审核文献关联。该条目正式发布前仍需要完成文献提取和专家复核。")
            for literature in literatures:
                render_literature(literature)


def ingredient_matches(ingredient, query):
    haystack = [
        ingredient.get("name_cn", ""),
        ingredient.get("name_en", ""),
        ingredient.get("category", ""),
        *[alias.get("alias", "") for alias in ingredient.get("aliases", [])],
    ]
    return any(query in item.lower() for item in haystack)


def target_matches(target, query):
    haystack = [
        target.get("name", ""),
        target.get("compliant_name", ""),
        target.get("description", ""),
        *[alias.get("alias", "") for alias in target.get("aliases", [])],
    ]
    return any(query in item.lower() for item in haystack)


def navigate_to_report(param_name, slug):
    other_param = "target" if param_name == "ingredient" else "ingredient"
    if other_param in st.query_params:
        del st.query_params[other_param]
    st.query_params[param_name] = slug
    st.rerun()


def report_button(label, param_name, slug, key):
    if st.button(label, key=key, use_container_width=True):
        navigate_to_report(param_name, slug)


def render_ingredient_report(ingredient, claims):
    st.title(ingredient["name_cn"])
    st.caption(f"{ingredient.get('category', '')} · {ingredient.get('name_en') or ''}")
    st.write(ingredient.get("summary") or "")
    if ingredient.get("safety_note"):
        st.warning(f"安全提示：{ingredient['safety_note']}")

    for claim in sorted(claims, key=claim_sort_key):
        render_claim(claim)


def render_target_report(target, claims):
    st.title(target["name"])
    st.caption(target.get("compliant_name", ""))
    st.write(target.get("description") or "")

    for claim in sorted(claims, key=claim_sort_key):
        render_claim(claim)


def render_search(data):
    st.title("营养品证据查询")
    st.write("输入成分、健康方向或商品名，查看证据强度、研究剂量和安全边界。")

    query = st.text_input("搜索", placeholder="例如：褪黑素、睡眠、鱼油、血脂")
    normalized = query.strip().lower()

    if not normalized:
        st.info("建议从“褪黑素”“鱼油”“睡眠”“血脂”开始。")
        st.markdown("#### 热门成分")
        for item in [
            ("褪黑素", "melatonin"),
            ("鱼油 / Omega-3", "omega-3"),
            ("镁", "magnesium"),
            ("肌酸", "creatine"),
            ("胶原蛋白肽", "collagen-peptides"),
            ("NMN", "nmn"),
        ]:
            report_button(item[0], "ingredient", item[1], f"home-ingredient-{item[1]}")
        return

    ingredient_results = [item for item in data["ingredients"] if ingredient_matches(item, normalized)]
    target_results = [item for item in data["health_targets"] if target_matches(item, normalized)]

    if not ingredient_results and not target_results:
        st.warning("未找到匹配项。当前体验版优先支持成分和健康方向，商品名需要先录入标签信息。")
        return

    if ingredient_results:
        st.subheader("成分")
        for item in ingredient_results[:10]:
            with st.container(border=True):
                st.markdown(f"**{item['name_cn']}**")
                st.caption(f"{item.get('name_en') or ''} · {item.get('category') or ''}")
                report_button("查看报告", "ingredient", item["slug"], f"search-ingredient-{item['slug']}")

    if target_results:
        st.subheader("健康方向")
        for item in target_results[:10]:
            with st.container(border=True):
                st.markdown(f"**{item['name']}**")
                st.caption(item.get("compliant_name") or "")
                report_button("查看相关成分", "target", item["slug"], f"search-target-{item['slug']}")


def main():
    st.set_page_config(
        page_title="营养品证据查询",
        page_icon="N",
        layout="wide",
        initial_sidebar_state="collapsed",
    )

    data, ingredients_by_slug, targets_by_slug, claims_by_ingredient, claims_by_target = load_data()

    with st.sidebar:
        st.markdown("## 营养品证据查询")
        st.caption("证据强度 · 可行性 · 安全风险")
        st.divider()
        st.markdown("### 热门成分")
        for label, slug in [
            ("褪黑素", "melatonin"),
            ("鱼油 / Omega-3", "omega-3"),
            ("镁", "magnesium"),
            ("肌酸", "creatine"),
            ("胶原蛋白肽", "collagen-peptides"),
            ("NMN", "nmn"),
        ]:
            report_button(label, "ingredient", slug, f"sidebar-ingredient-{slug}")
        st.divider()
        st.caption("当前为只读体验版。草稿结论用于产品验证，正式发布前需要完成人工文献复核。")
        st.caption(f"数据导出时间：{data['metadata'].get('generated_at')}")

    ingredient_slug = st.query_params.get("ingredient")
    target_slug = st.query_params.get("target")

    if ingredient_slug:
        ingredient = ingredients_by_slug.get(ingredient_slug)
        if not ingredient:
            st.error("未找到该成分。")
            return
        render_ingredient_report(ingredient, claims_by_ingredient.get(ingredient_slug, []))
        return

    if target_slug:
        target = targets_by_slug.get(target_slug)
        if not target:
            st.error("未找到该健康方向。")
            return
        render_target_report(target, claims_by_target.get(target_slug, []))
        return

    render_search(data)


if __name__ == "__main__":
    main()
