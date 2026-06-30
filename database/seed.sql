INSERT INTO ingredients (slug, name_cn, name_en, category, common_forms, summary, safety_note)
VALUES
  ('omega-3', 'Omega-3 / 鱼油 / EPA+DHA', 'Omega-3 fatty acids', '脂肪酸', '["鱼油", "EPA", "DHA", "藻油"]', '常见长链 Omega-3 脂肪酸，主要用于血脂相关指标和特定心血管问题的证据讨论。', '抗凝药使用者、术前人群和高剂量使用者需要谨慎。'),
  ('vitamin-d', '维生素D', 'Vitamin D', '维生素', '["维生素D3", "胆钙化醇", "维生素D2"]', '脂溶性维生素，与钙磷代谢、骨骼健康和缺乏纠正密切相关。', '过量可能导致高钙血症，肾病或高钙风险人群需谨慎。'),
  ('magnesium', '镁', 'Magnesium', '矿物质', '["甘氨酸镁", "柠檬酸镁", "氧化镁", "苏糖酸镁"]', '必需矿物质，涉及神经肌肉、能量代谢和部分睡眠相关研究。', '肾功能异常者不宜自行高剂量补充。'),
  ('melatonin', '褪黑素', 'Melatonin', '功能性成分', '["褪黑素片", "褪黑素软糖", "缓释褪黑素"]', '与昼夜节律相关的激素类补充剂，主要用于入睡时间和时差相关场景。', '儿童、孕哺期、精神疾病或合并镇静药物者需谨慎。'),
  ('probiotics', '益生菌', 'Probiotics', '微生态', '["乳酸菌", "双歧杆菌", "酵母菌"]', '活性微生物，作用高度依赖菌株、剂量和使用场景。', '免疫严重低下、中心静脉置管或重症人群需谨慎。'),
  ('prebiotics', '益生元 / 菊粉 / FOS', 'Prebiotics', '膳食纤维', '["菊粉", "低聚果糖", "FOS", "GOS"]', '可被肠道微生物利用的底物，常用于排便和肠道菌群相关讨论。', '易胀气人群、肠易激综合征人群需从低剂量开始评估耐受。'),
  ('psyllium-husk', '车前子壳', 'Psyllium husk', '膳食纤维', '["洋车前子壳", "车前子膳食纤维"]', '可溶性膳食纤维，与 LDL-C、排便和餐后血糖相关证据较多。', '需足量饮水；吞咽困难或肠梗阻风险人群不宜使用。'),
  ('beta-glucan', 'β-葡聚糖', 'Beta-glucan', '膳食纤维', '["燕麦β-葡聚糖", "大麦β-葡聚糖"]', '来自燕麦或大麦的可溶性纤维，常用于 LDL-C 相关指标。', '总体风险较低，胃肠不适较常见。'),
  ('plant-sterols', '植物甾醇', 'Plant sterols', '脂质类成分', '["植物甾醇酯", "植物固醇"]', '可影响肠道胆固醇吸收，主要用于 LDL-C 相关证据讨论。', '不适合植物甾醇血症人群；不替代血脂异常医学管理。'),
  ('coq10', '辅酶Q10', 'Coenzyme Q10', '辅酶', '["泛醌", "泛醇", "CoQ10"]', '参与线粒体能量代谢，常见于心血管和疲劳相关产品。', '华法林等抗凝药使用者需谨慎。'),
  ('creatine', '肌酸', 'Creatine', '运动营养', '["一水肌酸", "肌酸盐酸盐"]', '运动营养中证据较充分的成分，主要用于力量和高强度运动表现。', '肾病患者不宜自行使用；普通健康成人按研究剂量使用通常风险较低。'),
  ('whey-protein', '乳清蛋白', 'Whey protein', '蛋白质', '["乳清蛋白粉", "分离乳清", "浓缩乳清"]', '高质量蛋白来源，常用于运动营养、肌肉维持和蛋白摄入不足场景。', '乳制品过敏、严重肾病或需限制蛋白者需谨慎。'),
  ('collagen-peptides', '胶原蛋白肽', 'Collagen peptides', '蛋白肽', '["水解胶原蛋白", "胶原肽"]', '常用于皮肤弹性、含水量和关节舒适度相关研究。', '总体风险较低，但产品质量和蛋白来源需关注。'),
  ('lutein-zeaxanthin', '叶黄素 / 玉米黄质', 'Lutein and zeaxanthin', '类胡萝卜素', '["叶黄素酯", "游离叶黄素", "玉米黄质"]', '与黄斑色素和特定眼健康人群相关。', '总体风险较低，不应替代眼科诊疗。'),
  ('glucosamine', '葡萄糖胺', 'Glucosamine', '关节营养', '["氨糖", "硫酸氨基葡萄糖", "盐酸氨基葡萄糖"]', '常用于关节不适和骨关节相关研究，结论存在争议。', '甲壳类过敏、抗凝药使用者和糖代谢异常人群需谨慎。'),
  ('chondroitin', '软骨素', 'Chondroitin', '关节营养', '["硫酸软骨素"]', '常与葡萄糖胺复配，用于关节相关研究。', '抗凝药使用者需谨慎。'),
  ('curcumin', '姜黄素', 'Curcumin', '植物提取物', '["姜黄提取物", "高吸收姜黄素", "姜黄素磷脂复合物"]', '植物多酚类成分，生物利用度和剂型对研究解释影响较大。', '胆囊疾病、抗凝药使用者和术前人群需谨慎。'),
  ('calcium', '钙', 'Calcium', '矿物质', '["碳酸钙", "柠檬酸钙", "乳钙"]', '骨骼健康基础营养素，效果取决于基础摄入和维生素D状态。', '肾结石、高钙血症或肾病人群需谨慎。'),
  ('vitamin-k2', '维生素K2', 'Vitamin K2', '维生素', '["MK-7", "MK-4"]', '常用于骨骼和血管钙化相关宣传，但人体硬终点证据需谨慎。', '华法林使用者不宜自行补充。'),
  ('vitamin-c', '维生素C', 'Vitamin C', '维生素', '["抗坏血酸", "酯化维生素C"]', '水溶性维生素，缺乏纠正证据明确，普通免疫宣传需分场景。', '高剂量可能增加胃肠不适和部分人群结石风险。'),
  ('zinc', '锌', 'Zinc', '矿物质', '["葡萄糖酸锌", "吡啶甲酸锌", "柠檬酸锌"]', '必需微量元素，与缺乏纠正、免疫和皮肤相关场景有关。', '长期过量可能导致铜缺乏和胃肠反应。'),
  ('iron', '铁', 'Iron', '矿物质', '["硫酸亚铁", "富马酸亚铁", "甘氨酸亚铁"]', '缺铁和缺铁性贫血相关证据明确，但不适合无缺乏证据的人群随意补充。', '过量风险较高，儿童误服、铁过载和部分慢病人群需严格限制。'),
  ('folic-acid', '叶酸', 'Folic acid', '维生素', '["叶酸", "5-MTHF", "甲基叶酸"]', '孕前孕期神经管缺陷风险降低证据明确。', '高剂量可能掩盖维生素B12缺乏表现。'),
  ('vitamin-b12', '维生素B12', 'Vitamin B12', '维生素', '["钴胺素", "甲钴胺", "氰钴胺"]', '与缺乏纠正、素食人群和部分贫血/神经症状相关。', '总体风险较低，但症状性缺乏需医学评估。'),
  ('nmn', 'NMN', 'Nicotinamide mononucleotide', '功能性成分', '["β-NMN", "烟酰胺单核苷酸"]', '市场热度高，人体长期结局证据仍有限。', '长期安全性和特殊人群资料不足。'),
  ('l-carnitine', '左旋肉碱', 'L-carnitine', '氨基酸衍生物', '["L-肉碱", "乙酰左旋肉碱"]', '常用于体重管理宣传，但效果大小和适用人群需谨慎解释。', '可能引起胃肠反应，癫痫史人群需谨慎。'),
  ('green-tea-extract-egcg', '绿茶提取物 / EGCG', 'Green tea extract / EGCG', '植物提取物', '["EGCG", "儿茶素", "绿茶儿茶素"]', '常用于体重管理和抗氧化宣传，剂量与安全性边界重要。', '高剂量提取物存在肝损伤风险提示。'),
  ('alpha-lipoic-acid', 'α-硫辛酸', 'Alpha-lipoic acid', '抗氧化成分', '["硫辛酸", "ALA", "R-硫辛酸"]', '常用于糖代谢和神经症状相关研究，合规表达需谨慎。', '可能影响血糖，使用降糖药者需谨慎。'),
  ('gaba', 'GABA', 'Gamma-aminobutyric acid', '功能性成分', '["γ-氨基丁酸"]', '用于睡眠和压力相关宣传，人体证据仍有限。', '合并镇静类药物者需谨慎。'),
  ('l-theanine', 'L-茶氨酸', 'L-theanine', '氨基酸衍生物', '["茶氨酸"]', '茶叶中的氨基酸成分，常用于压力、专注和睡眠质量相关研究。', '总体风险较低，合并镇静药物者仍需谨慎。')
ON CONFLICT (slug) DO UPDATE SET
  name_cn = EXCLUDED.name_cn,
  name_en = EXCLUDED.name_en,
  category = EXCLUDED.category,
  common_forms = EXCLUDED.common_forms,
  summary = EXCLUDED.summary,
  safety_note = EXCLUDED.safety_note,
  updated_at = now();

WITH rows(slug, alias, language, priority) AS (
  VALUES
    ('omega-3', '鱼油', 'zh', 100), ('omega-3', 'EPA', 'en', 90), ('omega-3', 'DHA', 'en', 90), ('omega-3', 'Omega 3', 'en', 90),
    ('vitamin-d', '维D', 'zh', 90), ('vitamin-d', 'VD', 'zh', 80), ('vitamin-d', 'Vitamin D3', 'en', 80),
    ('magnesium', '甘氨酸镁', 'zh', 90), ('magnesium', '柠檬酸镁', 'zh', 90), ('magnesium', 'Magnesium', 'en', 80),
    ('melatonin', '褪黑素', 'zh', 100), ('melatonin', 'Melatonin', 'en', 80),
    ('probiotics', '益生菌', 'zh', 100), ('probiotics', 'Probiotic', 'en', 80),
    ('prebiotics', '益生元', 'zh', 100), ('prebiotics', '菊粉', 'zh', 90), ('prebiotics', 'FOS', 'en', 80),
    ('psyllium-husk', '车前子壳', 'zh', 100), ('psyllium-husk', '洋车前子', 'zh', 90), ('psyllium-husk', 'Psyllium', 'en', 80),
    ('beta-glucan', 'β葡聚糖', 'zh', 100), ('beta-glucan', '燕麦β葡聚糖', 'zh', 90), ('beta-glucan', 'Beta glucan', 'en', 80),
    ('plant-sterols', '植物甾醇', 'zh', 100), ('plant-sterols', '植物固醇', 'zh', 90),
    ('coq10', '辅酶Q10', 'zh', 100), ('coq10', 'CoQ10', 'en', 90),
    ('creatine', '肌酸', 'zh', 100), ('creatine', '一水肌酸', 'zh', 90),
    ('whey-protein', '乳清蛋白', 'zh', 100), ('whey-protein', '乳清蛋白粉', 'zh', 90),
    ('collagen-peptides', '胶原蛋白', 'zh', 100), ('collagen-peptides', '胶原蛋白肽', 'zh', 100),
    ('lutein-zeaxanthin', '叶黄素', 'zh', 100), ('lutein-zeaxanthin', '玉米黄质', 'zh', 90),
    ('glucosamine', '氨糖', 'zh', 100), ('glucosamine', '葡萄糖胺', 'zh', 100),
    ('chondroitin', '软骨素', 'zh', 100), ('chondroitin', '硫酸软骨素', 'zh', 90),
    ('curcumin', '姜黄素', 'zh', 100), ('curcumin', '姜黄提取物', 'zh', 90),
    ('calcium', '钙', 'zh', 100), ('calcium', '碳酸钙', 'zh', 90), ('calcium', '柠檬酸钙', 'zh', 90),
    ('vitamin-k2', '维生素K2', 'zh', 100), ('vitamin-k2', 'MK-7', 'en', 80),
    ('vitamin-c', '维生素C', 'zh', 100), ('vitamin-c', 'VC', 'zh', 80),
    ('zinc', '锌', 'zh', 100), ('zinc', '葡萄糖酸锌', 'zh', 90),
    ('iron', '铁', 'zh', 100), ('iron', '补铁', 'zh', 80),
    ('folic-acid', '叶酸', 'zh', 100), ('folic-acid', '甲基叶酸', 'zh', 90),
    ('vitamin-b12', '维生素B12', 'zh', 100), ('vitamin-b12', 'B12', 'zh', 80),
    ('nmn', 'NMN', 'en', 100), ('nmn', '烟酰胺单核苷酸', 'zh', 90),
    ('l-carnitine', '左旋肉碱', 'zh', 100), ('l-carnitine', 'L-肉碱', 'zh', 90),
    ('green-tea-extract-egcg', '绿茶提取物', 'zh', 100), ('green-tea-extract-egcg', 'EGCG', 'en', 90),
    ('alpha-lipoic-acid', 'α硫辛酸', 'zh', 100), ('alpha-lipoic-acid', '硫辛酸', 'zh', 90), ('alpha-lipoic-acid', 'ALA', 'en', 80),
    ('gaba', 'GABA', 'en', 100), ('gaba', 'γ-氨基丁酸', 'zh', 90),
    ('l-theanine', '茶氨酸', 'zh', 100), ('l-theanine', 'L-茶氨酸', 'zh', 100)
)
INSERT INTO ingredient_aliases (ingredient_id, alias, language, source, priority)
SELECT i.id, rows.alias, rows.language, 'seed', rows.priority
FROM rows
JOIN ingredients i ON i.slug = rows.slug
ON CONFLICT DO NOTHING;

INSERT INTO health_targets (slug, name, compliant_name, description, risk_level)
VALUES
  ('sleep', '睡眠', '睡眠质量相关', '入睡时间、睡眠质量和昼夜节律相关证据。', 'medium'),
  ('blood-lipids', '血脂', '血脂健康相关指标', 'LDL-C、甘油三酯等血脂相关指标。', 'high'),
  ('blood-glucose', '血糖', '糖代谢相关指标', '空腹血糖、餐后血糖、HbA1c 等糖代谢指标。', 'high'),
  ('gut-health', '肠道', '肠道健康相关', '排便、腹胀、肠道菌群和抗生素相关腹泻等场景。', 'medium'),
  ('joint-bone', '关节/骨骼', '关节舒适度和骨骼健康相关', '骨密度、骨折风险、关节疼痛或关节舒适度相关证据。', 'medium'),
  ('sports-performance', '运动表现', '运动表现和肌肉维持相关', '力量、功率、肌肉量、恢复和蛋白摄入相关证据。', 'low'),
  ('immune-health', '免疫', '免疫功能相关', '缺乏纠正、感染持续时间或特定免疫指标相关证据。', 'medium'),
  ('weight-management', '体重管理', '体重管理相关', '体重、体脂、食欲、能量摄入和代谢相关指标。', 'medium'),
  ('eye-health', '眼健康', '眼部健康相关', '黄斑、视觉功能和特定眼病风险人群相关证据。', 'medium'),
  ('skin-health', '皮肤', '皮肤健康相关', '皮肤含水量、弹性、皱纹指标和屏障功能相关证据。', 'low'),
  ('nutrient-status', '营养素缺乏/营养状态', '营养素补充和缺乏纠正相关', '铁、维生素B12等缺乏纠正或营养状态改善相关证据。', 'high'),
  ('maternal-nutrition', '备孕/孕期营养', '备孕和孕期营养补充相关', '备孕、孕早期和特殊生命阶段营养补充相关证据。', 'high')
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  compliant_name = EXCLUDED.compliant_name,
  description = EXCLUDED.description,
  risk_level = EXCLUDED.risk_level,
  updated_at = now();

WITH rows(slug, alias, rewrite, sensitive, blocked) AS (
  VALUES
    ('sleep', '失眠', '睡眠质量相关', true, false),
    ('sleep', '治失眠', '睡眠质量相关', true, true),
    ('sleep', '改善睡眠', '睡眠质量相关', false, false),
    ('blood-lipids', '降血脂', '血脂健康相关指标', true, false),
    ('blood-lipids', '高血脂', '血脂健康相关指标', true, false),
    ('blood-lipids', '治疗高脂血症', '血脂健康相关指标', true, true),
    ('blood-glucose', '降血糖', '糖代谢相关指标', true, false),
    ('blood-glucose', '糖尿病', '糖代谢相关指标', true, false),
    ('blood-glucose', '治疗糖尿病', '糖代谢相关指标', true, true),
    ('gut-health', '便秘', '排便和肠道健康相关', true, false),
    ('gut-health', '肠胃', '肠道健康相关', false, false),
    ('joint-bone', '关节痛', '关节舒适度相关', true, false),
    ('joint-bone', '骨质疏松', '骨骼健康相关', true, false),
    ('sports-performance', '增肌', '肌肉维持和运动表现相关', false, false),
    ('sports-performance', '运动恢复', '运动表现相关', false, false),
    ('immune-health', '提高免疫力', '免疫功能相关', true, false),
    ('immune-health', '预防感冒', '免疫功能相关', true, true),
    ('weight-management', '减肥', '体重管理相关', true, false),
    ('weight-management', '燃脂', '体重管理相关', true, false),
    ('weight-management', '快速减肥', '体重管理相关', true, true),
    ('eye-health', '护眼', '眼部健康相关', false, false),
    ('eye-health', '黄斑', '黄斑健康相关', true, false),
    ('skin-health', '美白', '皮肤健康相关', true, false),
    ('skin-health', '抗皱', '皮肤健康相关', false, false),
    ('nutrient-status', '贫血', '铁营养和血红蛋白相关指标', true, false),
    ('nutrient-status', '缺铁', '铁营养状态相关', true, false),
    ('nutrient-status', '素食营养', '维生素B12营养状态相关', false, false),
    ('maternal-nutrition', '备孕', '备孕营养补充相关', false, false),
    ('maternal-nutrition', '孕妇营养', '孕期营养补充相关', true, false),
    ('maternal-nutrition', '预防胎儿畸形', '备孕和孕早期营养补充相关', true, true)
)
INSERT INTO health_target_aliases (health_target_id, alias, display_rewrite, is_sensitive, blocked_term)
SELECT h.id, rows.alias, rows.rewrite, rows.sensitive, rows.blocked
FROM rows
JOIN health_targets h ON h.slug = rows.slug
ON CONFLICT DO NOTHING;

WITH rows(
  ingredient_slug, target_slug, title, population, outcome_metric,
  evidence_strength, feasibility, safety_risk, public_conclusion,
  dose_min, dose_max, dose_unit, dose_note, duration_min, duration_max, duration_unit,
  applicability, cautions, compliance_note
) AS (
  VALUES
    ('omega-3', 'blood-lipids', 'Omega-3 与甘油三酯', '甘油三酯偏高或相关风险人群', '甘油三酯', 'high', 'medium', 'medium', 'Omega-3 对降低甘油三酯有较明确证据，但通常需要较高 EPA+DHA 剂量，普通低剂量鱼油不能直接等同。', 2, 4, 'g/day EPA+DHA', '这里是研究中常见剂量范围，不是个人服用建议。', 8, 16, 'week', '甘油三酯偏高且已评估饮食、体重和药物管理需求的人群。', '抗凝药使用者、术前人群、出血风险人群。', '不得表述为治疗高脂血症或替代降脂药。'),
    ('vitamin-d', 'joint-bone', '维生素D 与骨骼健康', '维生素D不足、日晒不足或骨骼风险人群', '25(OH)D、骨密度、跌倒风险', 'high', 'high', 'medium', '维生素D用于纠正缺乏和支持骨骼健康证据明确，但普通人群超量补充不等于额外获益。', 400, 2000, 'IU/day', '剂量需结合检测、膳食、日晒和年龄评估。', 8, 52, 'week', '缺乏或摄入不足、老年人、骨骼风险较高人群。', '高钙血症、肾病、结石风险或正在使用相关药物者。', '不得宣称治疗骨质疏松。'),
    ('magnesium', 'sleep', '镁与睡眠质量', '摄入不足、老年或特定睡眠质量下降人群', '睡眠质量、入睡时间', 'medium', 'medium', 'medium', '镁对睡眠的证据受人群影响较大，可能更适合摄入不足或特定人群，不应泛化为治疗失眠。', 200, 500, 'mg/day elemental magnesium', '需区分元素镁剂量和化合物总量。', 4, 12, 'week', '镁摄入不足或存在肌肉紧张、睡眠质量下降的人群。', '肾功能异常者、合并多种药物者。', '避免使用“治疗失眠”。'),
    ('melatonin', 'sleep', '褪黑素与入睡时间', '昼夜节律紊乱、时差或短期入睡困难人群', '入睡潜伏期、节律调整', 'high', 'high', 'medium', '褪黑素对缩短入睡时间和调整昼夜节律证据较明确，但不适合被泛化为所有失眠问题的长期解决方案。', 0.5, 5, 'mg/day', '剂量和服用时间对结果影响较大。', 1, 8, 'week', '时差、作息后移、短期入睡困难人群。', '儿童、孕哺期、癫痫、精神疾病、镇静药或抗凝药使用者。', '避免表述为治疗失眠。'),
    ('probiotics', 'gut-health', '益生菌与肠道症状', '特定腹泻、抗生素相关腹泻或肠道症状人群', '腹泻发生率、腹胀、排便', 'medium', 'medium', 'medium', '益生菌的证据高度依赖菌株和场景，不能把“益生菌”作为一个整体直接判断有效。', NULL, NULL, 'CFU/day', '需记录菌株、活菌数和研究场景。', 1, 12, 'week', '抗生素相关腹泻风险、特定肠道症状人群。', '免疫严重低下、重症或中心静脉置管人群。', '不得泛称治疗肠病。'),
    ('prebiotics', 'gut-health', '益生元与排便和肠道菌群', '膳食纤维摄入不足或排便不规律人群', '排便频率、粪便性状、菌群指标', 'medium', 'high', 'low', '益生元对排便和菌群相关指标有一定证据，但胃肠耐受性决定实际可行性。', 3, 10, 'g/day', '从低剂量逐步增加通常更易耐受。', 2, 8, 'week', '膳食纤维摄入不足、排便不规律人群。', '肠易激综合征、明显腹胀或低FODMAP需求人群。', '避免宣称治疗便秘或肠病。'),
    ('psyllium-husk', 'blood-lipids', '车前子壳与 LDL-C', 'LDL-C偏高或膳食纤维摄入不足人群', 'LDL-C、总胆固醇', 'high', 'high', 'low', '车前子壳作为可溶性纤维，对 LDL-C 和排便相关指标有较实用证据，但需足量饮水。', 7, 12, 'g/day', '研究多使用每日数克级可溶性纤维。', 4, 12, 'week', '膳食纤维摄入不足、希望改善血脂相关指标的人群。', '吞咽困难、肠梗阻风险、需与药物错开服用者。', '不得宣称治疗高脂血症。'),
    ('beta-glucan', 'blood-lipids', 'β-葡聚糖与 LDL-C', 'LDL-C偏高或燕麦纤维摄入不足人群', 'LDL-C', 'high', 'high', 'low', '燕麦或大麦来源 β-葡聚糖对 LDL-C 有较明确证据，关键是达到有效纤维剂量。', 3, 4, 'g/day', '通常指燕麦或大麦 β-葡聚糖。', 4, 12, 'week', '希望通过膳食结构改善 LDL-C 相关指标的人群。', '胃肠敏感者需关注腹胀。', '不得宣称治疗高脂血症。'),
    ('plant-sterols', 'blood-lipids', '植物甾醇与 LDL-C', 'LDL-C偏高且需膳食管理的人群', 'LDL-C', 'high', 'high', 'low', '植物甾醇对降低 LDL-C 有较明确证据，但不替代整体饮食和医学管理。', 1.5, 3, 'g/day', '通常需每日规律摄入。', 4, 12, 'week', 'LDL-C偏高且正在进行膳食管理的人群。', '植物甾醇血症、孕哺期或儿童需专业评估。', '不得宣称治疗高胆固醇血症。'),
    ('coq10', 'sports-performance', '辅酶Q10 与疲劳相关指标', '特定疲劳或心血管相关用药背景人群', '疲劳评分、运动耐量', 'medium', 'medium', 'low', '辅酶Q10在部分疲劳和心血管相关场景有研究，但普通健康人群提升精力的证据不应夸大。', 100, 300, 'mg/day', '剂型和吸收差异较大。', 4, 12, 'week', '特定疲劳主诉、他汀相关肌肉症状讨论场景需专业评估。', '华法林等抗凝药使用者。', '避免宣称治疗心脏病或改善所有疲劳。'),
    ('creatine', 'sports-performance', '肌酸与力量运动表现', '阻力训练或高强度间歇运动人群', '最大力量、功率、瘦体重', 'high', 'high', 'low', '肌酸对力量和高强度运动表现证据较强，实际可行性高。', 3, 5, 'g/day', '常见维持剂量为每日 3-5 g；是否加载需按方案判断。', 4, 12, 'week', '规律阻力训练、高强度运动或肌肉维持需求人群。', '肾病患者、需限制肌酸酐解读的人群。', '不得宣称治疗肌少症或肾病相关问题。'),
    ('whey-protein', 'sports-performance', '乳清蛋白与肌肉维持', '蛋白摄入不足、阻力训练或老年肌肉维持人群', '总蛋白摄入、瘦体重、力量', 'high', 'high', 'low', '乳清蛋白可帮助达到每日蛋白目标，效果取决于总蛋白摄入、训练和能量状态。', 20, 40, 'g/serving protein', '应以每日总蛋白摄入为核心，而非单次产品剂量。', 8, 24, 'week', '蛋白摄入不足、运动训练或老年肌肉维持人群。', '牛奶蛋白过敏、严重肾病或需限制蛋白者。', '不得宣称治疗肌少症。'),
    ('collagen-peptides', 'skin-health', '胶原蛋白肽与皮肤指标', '关注皮肤含水量、弹性或轻度老化指标人群', '皮肤含水量、弹性、皱纹指标', 'medium', 'high', 'low', '胶原蛋白肽对部分皮肤指标有中等证据，但效果通常温和，不应等同于逆转衰老。', 2.5, 10, 'g/day', '不同原料和肽段差异可能影响结果。', 8, 12, 'week', '希望改善皮肤含水量或弹性等指标的人群。', '蛋白来源过敏者。', '避免宣称抗衰老或治疗皮肤病。'),
    ('lutein-zeaxanthin', 'eye-health', '叶黄素/玉米黄质与黄斑健康', '年龄相关黄斑风险或黄斑色素关注人群', '黄斑色素、AMD进展风险', 'high', 'medium', 'low', '叶黄素和玉米黄质对特定黄斑风险人群的证据较明确，普通护眼宣传需谨慎。', 10, 12, 'mg/day lutein', '常见研究还涉及玉米黄质组合。', 24, 260, 'week', 'AMD风险人群或经眼科评估需要营养支持的人群。', '已存在眼病症状者需眼科评估。', '不得宣称治疗眼病。'),
    ('glucosamine', 'joint-bone', '葡萄糖胺与关节不适', '骨关节相关不适人群', '疼痛评分、功能评分', 'low', 'medium', 'low', '葡萄糖胺用于关节不适的研究结论不一致，可能对部分人群有帮助，但不应强推荐。', 1500, 1500, 'mg/day', '硫酸盐和盐酸盐形式研究不能简单合并。', 8, 24, 'week', '骨关节相关不适且愿意进行有限试用的人群。', '甲壳类过敏、抗凝药使用者、糖代谢异常人群。', '不得宣称治疗骨关节炎。'),
    ('chondroitin', 'joint-bone', '软骨素与关节不适', '骨关节相关不适人群', '疼痛评分、功能评分', 'low', 'medium', 'low', '软骨素用于关节相关症状的证据存在争议，通常需要结合具体产品质量和研究设计判断。', 800, 1200, 'mg/day', '常见研究剂量为每日 800-1200 mg。', 8, 24, 'week', '骨关节相关不适且希望尝试营养支持的人群。', '抗凝药使用者。', '不得宣称治疗骨关节炎。'),
    ('curcumin', 'joint-bone', '姜黄素与关节舒适度', '关节不适或炎症相关指标关注人群', '疼痛评分、炎症指标', 'medium', 'medium', 'medium', '姜黄素对关节不适和部分炎症相关指标有一定研究，但吸收剂型差异很大。', 500, 1500, 'mg/day curcuminoids', '需注明是否为增强吸收剂型。', 4, 12, 'week', '轻中度关节不适且无明显禁忌的人群。', '胆囊疾病、抗凝药使用者、术前人群。', '不得宣称消炎或治疗关节炎。'),
    ('calcium', 'joint-bone', '钙与骨骼健康', '钙摄入不足或骨骼风险人群', '钙摄入量、骨密度、骨折风险', 'high', 'high', 'medium', '钙对骨骼健康属于基础营养支持，价值取决于基础摄入、维生素D状态和个体风险。', 500, 1200, 'mg/day total calcium', '应计算膳食和补充剂总钙摄入。', 12, 260, 'week', '钙摄入不足、老年或骨骼风险人群。', '肾结石、高钙血症、肾病或相关药物使用者。', '不得宣称治疗骨质疏松。'),
    ('vitamin-k2', 'joint-bone', '维生素K2 与骨骼相关指标', '骨骼健康关注人群', '骨密度、骨代谢指标', 'low', 'medium', 'medium', '维生素K2在骨骼相关指标上有研究，但证据强度和适用人群仍需谨慎界定。', 45, 180, 'mcg/day', 'MK-4 与 MK-7 剂量不可直接等同。', 12, 104, 'week', '骨骼健康关注且无抗凝药禁忌的人群。', '华法林使用者。', '不得宣称治疗骨质疏松或血管钙化。'),
    ('vitamin-c', 'immune-health', '维生素C 与免疫相关场景', '维生素C摄入不足、运动压力或普通感冒相关研究人群', '感冒持续时间、缺乏纠正', 'low', 'high', 'low', '维生素C纠正缺乏证据明确，但普通人群“提高免疫力”的泛化证据有限。', 200, 1000, 'mg/day', '高剂量不等于更好效果。', 1, 12, 'week', '摄入不足或特定压力场景人群。', '肾结石风险、胃肠敏感或铁过载风险人群。', '不得宣称预防或治疗感冒。'),
    ('zinc', 'immune-health', '锌与免疫相关指标', '锌摄入不足或特定感染持续时间研究人群', '锌状态、感冒持续时间、免疫指标', 'medium', 'high', 'medium', '锌对缺乏纠正意义明确，部分免疫相关场景有研究，但长期过量风险不能忽略。', 10, 40, 'mg/day elemental zinc', '应区分元素锌和化合物剂量。', 1, 12, 'week', '锌摄入不足或经评估存在缺乏风险的人群。', '长期高剂量、铜缺乏风险、胃肠敏感人群。', '不得宣称预防或治疗感染。'),
    ('iron', 'nutrient-status', '铁与缺铁相关疲劳/贫血', '缺铁或缺铁性贫血人群', '铁蛋白、血红蛋白、疲劳评分', 'high', 'high', 'high', '铁只适合缺铁或缺铁性贫血相关场景，不能作为普通疲劳或免疫补充剂随意使用。', 18, 100, 'mg/day elemental iron', '治疗性剂量必须由医生根据检测决定。', 8, 24, 'week', '明确缺铁、月经过多或孕期等缺铁风险人群。', '铁过载、儿童误服风险、慢性病贫血未明确病因者。', '不得引导无检测依据的人群补铁。'),
    ('folic-acid', 'maternal-nutrition', '叶酸与孕前孕期营养', '备孕和孕早期人群', '神经管缺陷风险、叶酸状态', 'high', 'high', 'medium', '叶酸在孕前孕早期降低神经管缺陷风险方面证据明确，但不属于普通免疫增强成分。', 400, 800, 'mcg/day', '特殊高风险孕妇剂量需医学评估。', 4, 52, 'week', '备孕和孕早期人群。', '维生素B12缺乏未排除者不宜长期高剂量。', '展示时应归入孕期营养或营养素补充，不宣称治疗。'),
    ('vitamin-b12', 'nutrient-status', '维生素B12 与缺乏纠正', '素食、老年、吸收不良或缺乏风险人群', 'B12状态、贫血和神经相关指标', 'high', 'high', 'low', '维生素B12用于缺乏纠正证据明确，普通人群额外补充不一定带来可感知收益。', 25, 1000, 'mcg/day', '剂量取决于缺乏程度、吸收情况和给药方式。', 4, 24, 'week', '素食者、老年人、胃肠吸收风险或检测提示不足者。', '已有神经症状或贫血者需医学评估。', '不得宣称治疗贫血或神经疾病。'),
    ('nmn', 'weight-management', 'NMN 与抗衰老/代谢宣传', '普通健康成人或代谢指标关注人群', 'NAD+相关指标、代谢指标', 'low', 'low', 'medium', 'NMN 人体长期结局证据不足，不应把机制指标等同于抗衰老效果。', 250, 600, 'mg/day', '不同研究剂量和终点差异大，长期安全性资料不足。', 4, 12, 'week', '仅适合以证据辨析方式展示，不建议作为强推荐。', '孕哺期、儿童、肿瘤相关风险或长期用药人群。', '避免抗衰老、逆转衰老等表述。'),
    ('l-carnitine', 'weight-management', '左旋肉碱与体重管理', '体重管理或运动人群', '体重、体脂、运动表现', 'low', 'low', 'medium', '左旋肉碱用于减脂的实际效果通常有限，不能替代能量控制和运动。', 1, 3, 'g/day', '体重管理研究效果大小需谨慎解释。', 8, 24, 'week', '可作为体重管理证据辨析，不建议作为主要方案。', '癫痫史、胃肠敏感或特殊鱼腥味代谢困扰人群。', '不得宣称燃脂或快速减肥。'),
    ('green-tea-extract-egcg', 'weight-management', '绿茶提取物/EGCG 与体重管理', '体重管理人群', '体重、能量消耗、脂肪氧化指标', 'low', 'medium', 'high', '绿茶提取物对体重管理效果有限且高剂量存在肝损伤风险，安全提示应优先展示。', 300, 800, 'mg/day EGCG', '高剂量 EGCG 风险增加，空腹使用需谨慎。', 8, 12, 'week', '不建议作为主要体重管理方案。', '肝病、饮酒较多、合并肝毒性药物或空腹高剂量使用者。', '不得宣称快速减肥或治疗肥胖。'),
    ('alpha-lipoic-acid', 'blood-glucose', 'α-硫辛酸与糖代谢相关指标', '糖代谢异常或神经症状相关研究人群', '空腹血糖、胰岛素抵抗、神经症状评分', 'medium', 'medium', 'medium', 'α-硫辛酸在糖代谢和神经症状相关研究中有一定证据，但不能替代糖尿病治疗。', 300, 600, 'mg/day', '使用降糖药者需关注低血糖风险。', 4, 24, 'week', '经专业评估的糖代谢异常或相关神经症状人群。', '使用降糖药、孕哺期、甲状腺疾病或低血糖风险人群。', '不得宣称治疗糖尿病或神经病变。'),
    ('gaba', 'sleep', 'GABA 与睡眠/压力', '睡眠质量下降或压力感受较高人群', '睡眠质量、压力评分', 'low', 'medium', 'low', 'GABA 口服补充用于睡眠和压力的证据仍有限，机制宣传不能替代人体结局证据。', 100, 300, 'mg/day', '不同产品剂量差异大，研究规模通常有限。', 1, 8, 'week', '适合做低风险但低证据的辨析条目。', '合并镇静药物、孕哺期或儿童。', '避免宣称抗焦虑或治疗失眠。'),
    ('l-theanine', 'sleep', 'L-茶氨酸与压力/睡眠质量', '压力感受高、睡眠质量下降或专注需求人群', '压力评分、睡眠质量、注意力指标', 'medium', 'high', 'low', 'L-茶氨酸对压力和睡眠质量相关指标有一定研究，安全性相对较好，但效果通常温和。', 100, 400, 'mg/day', '可单独或与咖啡因组合研究，终点需区分。', 1, 8, 'week', '压力感受较高、睡眠质量轻度下降或专注需求人群。', '合并镇静药物或孕哺期人群需谨慎。', '避免宣称治疗焦虑或失眠。')
)
INSERT INTO evidence_claims (
  ingredient_id, health_target_id, title, population, outcome_metric,
  evidence_strength, feasibility, safety_risk, public_conclusion,
  dose_min, dose_max, dose_unit, dose_note, duration_min, duration_max, duration_unit,
  applicability, cautions, compliance_note, status
)
SELECT
  i.id, h.id, rows.title, rows.population, rows.outcome_metric,
  rows.evidence_strength::evidence_strength, rows.feasibility::feasibility_level, rows.safety_risk::risk_level,
  rows.public_conclusion, rows.dose_min, rows.dose_max, rows.dose_unit, rows.dose_note,
  rows.duration_min, rows.duration_max, rows.duration_unit, rows.applicability, rows.cautions,
  rows.compliance_note || ' 当前为 v0.1 草稿，发布前必须完成人工文献复核。', 'draft'
FROM rows
JOIN ingredients i ON i.slug = rows.ingredient_slug
JOIN health_targets h ON h.slug = rows.target_slug
ON CONFLICT (ingredient_id, health_target_id, title) DO UPDATE SET
  population = EXCLUDED.population,
  outcome_metric = EXCLUDED.outcome_metric,
  evidence_strength = EXCLUDED.evidence_strength,
  feasibility = EXCLUDED.feasibility,
  safety_risk = EXCLUDED.safety_risk,
  public_conclusion = EXCLUDED.public_conclusion,
  dose_min = EXCLUDED.dose_min,
  dose_max = EXCLUDED.dose_max,
  dose_unit = EXCLUDED.dose_unit,
  dose_note = EXCLUDED.dose_note,
  duration_min = EXCLUDED.duration_min,
  duration_max = EXCLUDED.duration_max,
  duration_unit = EXCLUDED.duration_unit,
  applicability = EXCLUDED.applicability,
  cautions = EXCLUDED.cautions,
  compliance_note = EXCLUDED.compliance_note,
  status = 'draft',
  updated_at = now();

UPDATE evidence_claims ec
SET professional_conclusion = '当前草稿结论主要依据人体随机对照试验的系统综述/Meta 分析方向：褪黑素对入睡潜伏期、睡眠质量和昼夜节律相关结局存在较一致的短期研究支持，但研究人群、给药时间、剂量和结局指标存在异质性。该结论不应外推为长期治疗所有失眠问题。'
FROM ingredients i, health_targets h
WHERE ec.ingredient_id = i.id
  AND ec.health_target_id = h.id
  AND i.slug = 'melatonin'
  AND h.slug = 'sleep'
  AND ec.title = '褪黑素与入睡时间';

INSERT INTO literatures (
  title, year, journal, study_type, pmid, doi, url, abstract, population,
  intervention, outcomes, limitations, source
)
VALUES
  (
    'Effect of melatonin supplementation on sleep quality: a systematic review and meta-analysis of randomized controlled trials.',
    2022,
    'Journal of Neurology',
    'meta_analysis',
    '33417003',
    '10.1007/s00415-020-10381-w',
    'https://pubmed.ncbi.nlm.nih.gov/33417003/',
    'Systematic review and meta-analysis of randomized clinical trials assessing melatonin and sleep quality in adults with various diseases.',
    'Adults in randomized clinical trials across several health conditions.',
    'Melatonin supplementation.',
    'Sleep quality assessed mainly by Pittsburgh Sleep Quality Index and subgroup analyses.',
    'Substantial heterogeneity across included studies; results vary by health status and intervention details.',
    'PubMed'
  ),
  (
    'Optimizing the Time and Dose of Melatonin as a Sleep-Promoting Drug: A Systematic Review of Randomized Controlled Trials and Dose-Response Meta-Analysis.',
    2024,
    'Journal of Pineal Research',
    'meta_analysis',
    '38888087',
    '10.1111/jpi.12985',
    'https://pubmed.ncbi.nlm.nih.gov/38888087/',
    'Systematic review and dose-response meta-analysis of double-blind randomized controlled trials on melatonin timing and dose for sleep-related parameters.',
    'Patients with insomnia and healthy volunteers in randomized controlled trials.',
    'Exogenous melatonin with varying dose and timing.',
    'Sleep onset latency and total sleep time.',
    'Dose, timing, insomnia status and study design differences affect interpretation.',
    'PubMed'
  )
ON CONFLICT DO NOTHING;

UPDATE literatures
SET
  title = 'Effect of melatonin supplementation on sleep quality: a systematic review and meta-analysis of randomized controlled trials.',
  year = 2022,
  journal = 'Journal of Neurology',
  study_type = 'meta_analysis',
  doi = '10.1007/s00415-020-10381-w',
  url = 'https://pubmed.ncbi.nlm.nih.gov/33417003/',
  abstract = 'Systematic review and meta-analysis of randomized clinical trials assessing melatonin and sleep quality in adults with various diseases.',
  population = 'Adults in randomized clinical trials across several health conditions.',
  intervention = 'Melatonin supplementation.',
  outcomes = 'Sleep quality assessed mainly by Pittsburgh Sleep Quality Index and subgroup analyses.',
  limitations = 'Substantial heterogeneity across included studies; results vary by health status and intervention details.',
  source = 'PubMed',
  updated_at = now()
WHERE pmid = '33417003';

UPDATE literatures
SET
  title = 'Optimizing the Time and Dose of Melatonin as a Sleep-Promoting Drug: A Systematic Review of Randomized Controlled Trials and Dose-Response Meta-Analysis.',
  year = 2024,
  journal = 'Journal of Pineal Research',
  study_type = 'meta_analysis',
  doi = '10.1111/jpi.12985',
  url = 'https://pubmed.ncbi.nlm.nih.gov/38888087/',
  abstract = 'Systematic review and dose-response meta-analysis of double-blind randomized controlled trials on melatonin timing and dose for sleep-related parameters.',
  population = 'Patients with insomnia and healthy volunteers in randomized controlled trials.',
  intervention = 'Exogenous melatonin with varying dose and timing.',
  outcomes = 'Sleep onset latency and total sleep time.',
  limitations = 'Dose, timing, insomnia status and study design differences affect interpretation.',
  source = 'PubMed',
  updated_at = now()
WHERE pmid = '38888087';

WITH claim AS (
  SELECT ec.id
  FROM evidence_claims ec
  JOIN ingredients i ON i.id = ec.ingredient_id
  JOIN health_targets h ON h.id = ec.health_target_id
  WHERE i.slug = 'melatonin'
    AND h.slug = 'sleep'
    AND ec.title = '褪黑素与入睡时间'
),
links(pmid, evidence_role, weight, extracted_dose, extracted_duration, extracted_result, reviewer_note) AS (
  VALUES
    (
      '38888087',
      'primary',
      5,
      'Dose-response review; reported peak around 4 mg/day in included trials.',
      'RCTs published between 1987 and 2020.',
      'Reported reductions in sleep onset latency and increases in total sleep time; timing and dose materially affected results.',
      'Seeded demonstration link; requires expert verification before publication.'
    ),
    (
      '33417003',
      'supporting',
      4,
      'Varied across included randomized trials.',
      'Varied across included randomized trials.',
      'Meta-analysis found improved PSQI sleep quality scores overall, with significant heterogeneity.',
      'Seeded demonstration link; requires expert verification before publication.'
    )
)
INSERT INTO evidence_claim_literatures (
  evidence_claim_id, literature_id, evidence_role, weight,
  extracted_dose, extracted_duration, extracted_result, reviewer_note
)
SELECT claim.id, l.id, links.evidence_role::evidence_role, links.weight,
       links.extracted_dose, links.extracted_duration, links.extracted_result, links.reviewer_note
FROM claim
JOIN links ON true
JOIN literatures l ON l.pmid = links.pmid
ON CONFLICT DO NOTHING;

INSERT INTO coupons (code, name, coupon_type, query_count, max_redemptions, per_user_limit, starts_at, expires_at, status)
VALUES
  ('WELCOME3', '新用户 3 次完整报告体验券', 'query_credit', 3, NULL, 1, now(), now() + interval '365 days', 'active')
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  coupon_type = EXCLUDED.coupon_type,
  query_count = EXCLUDED.query_count,
  max_redemptions = EXCLUDED.max_redemptions,
  per_user_limit = EXCLUDED.per_user_limit,
  starts_at = EXCLUDED.starts_at,
  expires_at = EXCLUDED.expires_at,
  status = EXCLUDED.status,
  updated_at = now();
