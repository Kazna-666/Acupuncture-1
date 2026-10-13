import 'l10n.dart';

/// Классический фитопрепарат ТКМ
class TcmFormula {
  final String id;
  final T3 name;
  final String hanzi;
  final String composition;
  final T3 action;
  const TcmFormula(this.id, this.name, this.hanzi, this.composition, this.action);
}

/// Синдром ТКМ с рецептом точек и ссылкой на формулу
class TcmSyndrome {
  final T3 name;
  final T3 manifest;
  final List<String> points;
  final String? formulaId;
  const TcmSyndrome(this.name, this.manifest, this.points, this.formulaId);
}

class ClinicalData {
  static const List<TcmFormula> formulas = [
    TcmFormula('sijunzi', T3('Сы-цзюнь-цзы тан', 'Four Gentlemen Decoction', '四君子汤'), '四君子汤',
        'Жэнь-шэнь 人参 (или дан-шэнь 党参), бай-чжу 白术, фу-лин 茯苓, гань-цао 甘草',
        T3('Тонизирует ци селезёнки и желудка — базовая формула при слабости пищеварения',
            'Tonifies spleen and stomach qi — the base formula for digestive weakness',
            '益气健脾——脾胃气虚之基础方')),
    TcmFormula('liuwei', T3('Лю-вэй ди хуан вань', 'Six-Ingredient Rehmannia Pill', '六味地黄丸'), '六味地黄丸',
        'Шу-ди-хуан 熟地黄, шань-чжу-юй 山茱萸, шань-яо 山药, цзэ-се 泽泻, му-дань-пи 牡丹皮, фу-лин 茯苓',
        T3('Питает инь почек и печени: головокружение, звон в ушах, жар в ладонях',
            'Nourishes liver-kidney yin: dizziness, tinnitus, heat in palms',
            '滋阴补肾——肝肾阴虚，头晕耳鸣，腰膝酸软')),
    TcmFormula('buzhong', T3('Бу-чжун и-ци тан', 'Central Qi Tonifying Decoction', '补中益气汤'), '补中益气汤',
        'Хуан-ци 黄芪, жэнь-шэнь 人参, бай-чжу 白术, гань-цао 甘草, дан-гуй 当归, чэнь-пи 陈皮, шэн-ма 升麻, чай-ху 柴胡',
        T3('Поднимает опущенную ци: пролапсы, астения, хроническая усталость',
            'Raises sunken qi: prolapse, asthenia, chronic fatigue',
            '补中益气，升阳举陷——气虚下陷，久泻脱肛')),
    TcmFormula('guizhi', T3('Гуй-чжи тан', 'Cinnamon Twig Decoction', '桂枝汤'), '桂枝汤',
        'Гуй-чжи 桂枝, шао-яо 芍药, шэн-цзян 生姜, да-цзао 大枣, гань-цао 甘草',
        T3('Освобождает поверхность при ветре-холоде с потливостью; гармонизирует инь-ян',
            'Releases the exterior in wind-cold with sweating; harmonizes yin-yang',
            '解肌发表，调和营卫——风寒表虚证')),
    TcmFormula('mahuang', T3('Ма-хуан тан', 'Ephedra Decoction', '麻黄汤'), '麻黄汤',
        'Ма-хуан 麻黄, гуй-чжи 桂枝, син-жэнь 杏仁, гань-цао 甘草',
        T3('Мощное потогонное при ветре-холоде без пота, кашель, одышка',
            'Strong diaphoretic for wind-cold without sweating, cough, dyspnea',
            '发汗解表，宣肺平喘——风寒表实证')),
    TcmFormula('yinqiao', T3('Инь-цяо сань', 'Lonicera and Forsythia Powder', '银翘散'), '银翘散',
        'Инь-хуа 金银花, лянь-цяо 连翘, бо-хэ 薄荷, цзин-цзе 荆芥, дань-доу-чи 淡豆豉, ню-бан-цзы 牛蒡子, цзе-гэн 桔梗, чжу-е 淡竹叶, лу-гэнь 芦根, гань-цао 甘草',
        T3('Ветер-жар: боль в горле, жар, головная боль',
            'Wind-heat: sore throat, fever, headache',
            '辛凉透表，清热解毒——温病初起')),
    TcmFormula('xiaochaihu', T3('Сяо-чай-ху тан', 'Minor Bupleurum Decoction', '小柴胡汤'), '小柴胡汤',
        'Чай-ху 柴胡, хуан-цинь 黄芩, бань-ся 半夏, шэн-цзян 生姜, жэнь-шэнь 人参, гань-цао 甘草, да-цзао 大枣',
        T3('Регулирует шао-ян: горечь во рту, чередование озноба и жара, пульсация в боку',
            'Harmonizes shaoyang: bitter mouth, alternating chills and fever, flank fullness',
            '和解少阳——往来寒热，胸胁苦满')),
    TcmFormula('xiaoyao', T3('Сяо-яо сань', 'Carefree Powder', '逍遥散'), '逍遥散',
        'Чай-ху 柴胡, дан-гуй 当归, бай-шао 白芍, бай-чжу 白术, фу-лин 茯苓, гань-цао 甘草, бо-хэ 薄荷, шэн-цзян 生姜',
        T3('Смягчает печень, укрепляет селезёнку: стресс, ПМС, депрессия',
            'Soothes the liver, strengthens the spleen: stress, PMS, depression',
            '疏肝解郁，养血健脾——肝郁血虚脾弱')),
    TcmFormula('shengmai', T3('Шэн-май сань', 'Generate the Pulse Powder', '生脉散'), '生脉散',
        'Жэнь-шэнь 人参, май-мэнь-дун 麦门冬, у-вэй-цзы 五味子',
        T3('Тонизирует ци и инь сердца и лёгких: потливость, слабый пульс, жажда',
            'Tonifies heart-lung qi and yin: sweating, weak pulse, thirst',
            '益气生津，敛阴止汗——气阴两伤')),
    TcmFormula('guipi', T3('Гуй-пи тан', 'Spleen-Restoring Decoction', '归脾汤'), '归脾汤',
        'Хуан-ци 黄芪, жэнь-шэнь 人参, бай-чжу 白术, дан-гуй 当归, фу-шэнь 茯神, юань-чжи 远志, суань-цзао-жэнь 酸枣仁, лун-янь-жоу 龙眼肉, му-сян 木香, гань-цао 甘草',
        T3('Питает кровь сердца, успокаивает дух: бессонница, забывчивость, анемия',
            'Nourishes heart blood, calms the spirit: insomnia, forgetfulness, anemia',
            '益气补血，健脾养心——心脾气血两虚')),
    TcmFormula('tianwang', T3('Тянь-ван бу-синь дань', 'Emperor of Heaven Heart-Tonifying Pill', '天王补心丹'), '天王补心丹',
        'Шэн-ди-хуан 生地黄, жэнь-шэнь 人参, сюань-шэнь 玄参, тянь-мэнь-дун 天门冬, май-мэнь-дун 麦门冬, дан-шэнь 丹参, фу-лин 茯苓, юань-чжи 远志, суань-цзао-жэнь 酸枣仁, бай-цзы-жэнь 柏子仁, у-вэй-цзы 五味子, дан-гуй 当归, цзе-гэн 桔梗',
        T3('Питает инь сердца: бессонница с тревогой, сухость, забытьё',
            'Nourishes heart yin: anxious insomnia, dryness, forgetfulness',
            '滋阴清热，养血安神——阴虚血少，神志不安')),
    TcmFormula('pingwei', T3('Пин-вэй сань', 'Stomach-Calming Powder', '平胃散'), '平胃散',
        'Цан-чжу 苍术, хоу-по 厚朴, чэнь-пи 陈皮, гань-цао 甘草',
        T3('Осушает сырость, движет ци желудка: тяжесть, вздутие, вялость',
            'Dries dampness, moves stomach qi: heaviness, bloating, lethargy',
            '燥湿运脾，行气和胃——湿滞脾胃')),
    TcmFormula('erchen', T3('Эр-чэнь тан', 'Two Aged Ingredients Decoction', '二陈汤'), '二陈汤',
        'Бань-ся 半夏, чэнь-пи 陈皮, фу-лин 茯苓, гань-цао 甘草, у-мэй 乌梅, шэн-цзян 生姜',
        T3('Сушит флегму: кашель с мокротой, тошнота, головокружение',
            'Dries phlegm: cough with sputum, nausea, dizziness',
            '燥湿化痰，理气和中——痰湿咳嗽')),
    TcmFormula('xuefu', T3('Сюэ-фу чжу-ю тан', 'Drive Out Blood in the Mansion Decoction', '血府逐瘀汤'), '血府逐瘀汤',
        'Тао-жэнь 桃仁, хун-хуа 红花, дан-гуй 当归, чуань-сюн 川芎, чи-шао 赤芍, шэн-ди-хуан 生地黄, ню-си 牛膝, чжи-кэ 枳壳, цзе-гэн 桔梗, чай-ху 柴胡, гань-цао 甘草',
        T3('Движет кровь, устраняет застой: дисменорея, боли фиксированные, травмы',
            'Moves blood, dispels stasis: dysmenorrhea, fixed pain, trauma',
            '活血化瘀，行气止痛——胸中血瘀')),
  ];

  static const List<TcmSyndrome> syndromes = [
    TcmSyndrome(
        T3('Простуда: ветер-холод', 'Common cold: wind-cold', '感冒：风寒证'),
        T3('Озноб, ломота, светлая мокрота, нет пота, светлый язык',
            'Chills, aching body, clear sputum, no sweat, pale tongue',
            '恶寒重、无汗、流清涕、咳嗽白痰、舌苔薄白'),
        ['LU7', 'LI4', 'GB20', 'BL12', 'GV14'], 'guizhi'),
    TcmSyndrome(
        T3('Простуда: ветер-жар', 'Common cold: wind-heat', '感冒：风热证'),
        T3('Жар, боль в горле, жёлтая мокрота, потливость, жажда',
            'Fever, sore throat, yellow sputum, sweating, thirst',
            '发热重、咽喉肿痛、流黄涕、汗出、口渴'),
        ['LU5', 'LI4', 'LI11', 'TE5', 'GV14'], 'yinqiao'),
    TcmSyndrome(
        T3('Головная боль (восхождение ян печени)', 'Headache (liver yang rising)', '头痛：肝阳上亢'),
        T3('Пульсирующая боль в висках и темени, раздражительность, красное лицо',
            'Pulsating temple and vertex pain, irritability, red face',
            '头痛眩晕、烦躁易怒、面红目赤'),
        ['LR3', 'GB20', 'GV20', 'LI4', 'EX-HN5'], 'xiaoyao'),
    TcmSyndrome(
        T3('Мигрень (шао-ян)', 'Migraine (shaoyang)', '偏头痛：少阳经'),
        T3('Односторонняя боль, тошнота, светобоязнь, приступы после стресса',
            'Unilateral pain, nausea, photophobia, stress-triggered attacks',
            '一侧头痛、恶心呕吐、视物闪光'),
        ['GB20', 'GB39', 'GB8', 'TE5', 'LR3'], 'xiaochaihu'),
    TcmSyndrome(
        T3('Головокружение и гипертензия', 'Dizziness and hypertension', '眩晕：肝肾阴虚'),
        T3('Вращение головы, звон в ушах, жар в пятках, покраснение языка',
            'Spinning vertigo, tinnitus, hot soles, red tongue',
            '眩晕耳鸣、腰膝酸软、五心烦热'),
        ['LR3', 'KI3', 'GB20', 'GV20', 'ST36'], 'liuwei'),
    TcmSyndrome(
        T3('Бессонница (дефицит сердца и селезёнки)', 'Insomnia (heart-spleen deficiency)', '不寐：心脾两虚'),
        T3('Трудное засыпание, много снов, усталость, бледный язык, плохой аппетит',
            'Difficulty falling asleep, many dreams, fatigue, pale tongue, poor appetite',
            '入睡困难、多梦易醒、心悸健忘、食少乏力'),
        ['HT7', 'PC6', 'SP6', 'BL15', 'GV20'], 'guipi'),
    TcmSyndrome(
        T3('Сердцебиение и тревога', 'Palpitations and anxiety', '心悸：心气不足'),
        T3('Учащённое сердце при нагрузке, страх, потливость, слабый пульс',
            'Fast heart on exertion, fear, sweating, weak pulse',
            '心悸气短、神疲乏力、动则加重'),
        ['PC6', 'HT7', 'BL15', 'CV17', 'KI3'], 'shengmai'),
    TcmSyndrome(
        T3('Кашель (жар лёгких)', 'Cough (lung heat)', '咳嗽：痰热蕴肺'),
        T3('Жёлтая густая мокрота, жар, боль в груди, сухость во рту',
            'Thick yellow sputum, fever, chest pain, dry mouth',
            '咳嗽气粗、痰黄粘稠、口干咽痛'),
        ['LU5', 'LU7', 'BL13', 'LI4', 'ST40'], 'yinqiao'),
    TcmSyndrome(
        T3('Одышка/астма (дефицит лёгких и почек)', 'Dyspnea/asthma (lung-kidney deficiency)', '哮病：肺肾两虚'),
        T3('Одышка при движении, тихий голос, свист ночью, страх холода',
            'Dyspnea on exertion, faint voice, night wheeze, cold aversion',
            '动则气喘、咳声低弱、畏寒肢冷'),
        ['BL13', 'BL23', 'LU9', 'KI3', 'CV17'], 'liuwei'),
    TcmSyndrome(
        T3('Боль в эпигастрии (холод в желудке)', 'Epigastric pain (stomach cold)', '胃痛：寒邪犯胃'),
        T3('Резкая боль, тепло облегчает, рвота прозрачной жидкостью',
            'Sharp pain, warmth relieves, vomiting clear fluid',
            '胃痛暴作、得温痛减、呕吐清水'),
        ['CV12', 'ST36', 'BL21', 'PC6', 'LI4'], 'pingwei'),
    TcmSyndrome(
        T3('Тошнота и рвота', 'Nausea and vomiting', '呕吐：胃失和降'),
        T3('Тошнота от запахов, вздутие, икота, плохой аппетит',
            'Nausea from smells, bloating, hiccups, poor appetite',
            '恶心呕吐、脘腹胀满、嗳气'),
        ['PC6', 'ST36', 'CV12', 'ST40', 'SP4'], 'erchen'),
    TcmSyndrome(
        T3('Запор (сухость кишечника)', 'Constipation (dry intestine)', '便秘：津亏肠燥'),
        T3('Сухой стул раз в 3-5 дней, вздутие, сухой язык',
            'Dry stool every 3-5 days, bloating, dry tongue',
            '大便干结、数日一行、口干咽燥'),
        ['ST25', 'TE6', 'BL25', 'LI4', 'SP15'], 'buzhong'),
    TcmSyndrome(
        T3('Диарея (холод-сырость селезёнки)', 'Diarrhea (spleen cold-damp)', '泄泻：脾虚湿盛'),
        T3('Жидкий стул после еды, вздутие, слабость, белый налёт',
            'Loose stool after eating, bloating, fatigue, white coating',
            '大便溏薄、食后腹胀、神疲肢倦'),
        ['ST36', 'SP6', 'SP9', 'CV12', 'BL20'], 'buzhong'),
    TcmSyndrome(
        T3('Геморрой', 'Hemorrhoids', '痔疮'),
        T3('Боль и зуд заднего прохода, кровь в стуле, узлы',
            'Anal pain and itching, blood in stool, nodes',
            '便血、肛门肿痛、痔核脱出'),
        ['BL57', 'BL40', 'GV1', 'SI3', 'BL62'], null),
    TcmSyndrome(
        T3('Люмбаго (дефицит почек)', 'Lumbago (kidney deficiency)', '腰痛：肾虚'),
        T3('Тупая боль в пояснице, слабость ног, улучшение в покое',
            'Dull lumbar pain, weak legs, relief with rest',
            '腰膝酸软、绵绵作痛、劳则加重'),
        ['BL23', 'GV4', 'BL40', 'BL60', 'KI3'], 'liuwei'),
    TcmSyndrome(
        T3('Шейный синдром', 'Cervical syndrome', '项痹：经络阻滞'),
        T3('Скованность и боль в шее, боль в затылке, онемение рук',
            'Neck stiffness and pain, occipital pain, numb hands',
            '颈项强痛、活动受限、手臂麻木'),
        ['GB20', 'SI3', 'BL10', 'GV14', 'LI4'], 'guizhi'),
    TcmSyndrome(
        T3('Замороженное плечо', 'Frozen shoulder', '肩凝症'),
        T3('Боль и ограничение подъёма руки, боль ночью',
            'Pain and limited arm elevation, night pain',
            '肩部疼痛、上举外展受限、夜间痛甚'),
        ['LI15', 'TE14', 'GB21', 'SI11', 'LI4'], 'guizhi'),
    TcmSyndrome(
        T3('Ишиас', 'Sciatica', '坐骨神经痛'),
        T3('Боль от ягодицы к пятке, усиление при наклоне, онемение',
            'Pain from buttock to heel, worse on bending, numbness',
            '腰腿痛沿大腿后侧放射、咳嗽加重'),
        ['GB30', 'BL54', 'BL40', 'BL60', 'GB34'], null),
    TcmSyndrome(
        T3('Артроз колена', 'Knee osteoarthritis', '膝痹'),
        T3('Боль и хруст в колене, скованность утром, слабость',
            'Knee pain and crepitus, morning stiffness, weakness',
            '膝关节疼痛、上下楼困难、晨僵'),
        ['ST35', 'ST36', 'SP9', 'GB34', 'BL40'], null),
    TcmSyndrome(
        T3('Дисменорея (застой крови)', 'Dysmenorrhea (blood stasis)', '痛经：气滞血瘀'),
        T3('Схваткообразная боль до менструации, тёмные сгустки',
            'Cramping pain before menses, dark clots',
            '经前或经期小腹刺痛、血块多、舌紫暗'),
        ['SP6', 'SP8', 'CV4', 'CV6', 'LR3'], 'xuefu'),
    TcmSyndrome(
        T3('Укачивание', 'Motion sickness', '晕动病'),
        T3('Тошнота, головокружение, бледность, рвота в транспорте',
            'Nausea, dizziness, pallor, vomiting in transport',
            '乘车乘船恶心呕吐、头晕、面色苍白'),
        ['PC6', 'ST36', 'GB8', 'CV12', 'EX-HN3'], 'erchen'),
    TcmSyndrome(
        T3('Астения (дефицит ци)', 'Asthenia (qi deficiency)', '虚劳：气虚'),
        T3('Усталость, одышка, тихий голос, потливость, слабый аппетит',
            'Fatigue, dyspnea, faint voice, sweating, poor appetite',
            '神疲乏力、少气懒言、自汗、食少'),
        ['ST36', 'SP6', 'CV6', 'CV4', 'BL20'], 'buzhong'),
  ];
}
