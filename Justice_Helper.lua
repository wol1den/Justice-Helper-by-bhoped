---@diagnostic disable: undefined-global, need-check-nil, lowercase-global, cast-local-type, unused-local

script_name("Justice Helper")
script_description('This is a Cross-platform Lua script helper for Arizona RP players who work in the Ministry of Justice (PD and FBI) ??and the Ministry of Defense (Army)')
script_author("MTG MODS (and edited by bhoped)")
script_version("1.2 ALPHA")

require('lib.moonloader')
require ('encoding').default = 'CP1251'
local u8 = require('encoding').UTF8
local ffi = require('ffi')
local sampev = require('samp.events')
-------------------------------------------- JSON SETTINGS ---------------------------------------------
local settings = {}
local default_settings = {
	general = {
		version = thisScript().version,
		accent_enable = true,
		auto_mask = true,
		rp_chat = true,
        rp_gun = true,
		auto_doklad_patrool = true,
		auto_doklad_damage = true,
		auto_doklad_arrest = true,
		auto_change_code_siren = true,
		auto_update_wanteds = true,
		auto_update_members = true,
		auto_notify_payday = true,
		auto_notify_port = true,
		auto_uval = false,
		auto_clicker_situation = true,
		use_form_su = false,
		moonmonet_theme_enable = true,
		moonmonet_theme_color = 40703,
		mobile_fastmenu_button = true,
		mobile_stop_button = true,
		use_binds = true,
		use_info_menu = true,
		bind_mainmenu = '[113]',
		bind_fastmenu = '[69]',
		bind_leader_fastmenu = '[71]',
		bind_command_stop = '[123]'
	},
	player_info = {
		name_surname = '',
		accent = '[Иностранный акцент]:',
		fraction = 'Неизвестно',
		fraction_tag = 'Неизвестно',
		fraction_rank = 'Неизвестно',
		fraction_rank_number = 0,
		sex = 'Неизвестно',
	},
	deportament = {
		dep_fm = '-',
		dep_tag1 = '',
		dep_tag2 = '[Всем]',
		dep_tags = {
			"[Всем]",
			"[Похитители]",
			"[Терористы]",
			"[Диспетчер]",
			'skip',
			"[МЮ]",
			"[Мин.Юст.]",
			"[ЛСПД]",
			"[СФПД]",
			"[ЛВПД]",
			"[РКШД]",
			"[СВАТ]",
			"[ФБР]",
			'skip',
			"[МО]",
			"[Мин.Обороны]",
			"[ЛСа]",
			"[СФа]",
			"[ТСР]",
			'skip',
			"[МЗ]",
			"[Мин.Здрав.]",
			"[ЛСМЦ]",
			"[СФМЦ]",
			"[ЛВМЦ]",
			"[ДМЦ]",
			'skip',
			"[ЦА]",
			"[ЦЛ]",
			"[СК]",
			"[Пра-во]",
			"[Губернатор]",
			"[Прокурор]",
			'skip',
			"[СМИ]",
			"[СМИ ЛС]",
			"[СМИ СФ]",
			"[СМИ ЛВ]",
		},
		dep_tags_en = {
			"[ALL]",
			'skip',
			"[MJ]",
			"[Min.Just.]",
			"[LSPD]",
			"[SFPD]",
			"[LVPD]",
			"[RCSD]",
			"[SWAT]",
			"[FBI]",
			'skip',
			"[MD]",
			"[Mid.Def.]",
			"[LSa]",
			"[SFa]",
			"[MSP]",
			'skip',
			"[MH]",
			"[Min.Healt]",
			"[LSMC]",
			"[SFMC]",
			"[LVMC]",
			"[JMC]",
			'skip',
			"[GOV]",
			"[Prosecutor]",
			"[LC]",
			"[INS]",
			'skip',
			"[CNN]",
			"[CNN LS]",
			"[CNN LV]",
			"[CNN SF]",
		},
		dep_tags_custom = {},
		dep_fms = {
			'-',
			'- з.к. -',
			'- 101.1 FM - ',

		},
	},
}
local configDirectory = getWorkingDirectory():gsub('\\','/') .. "/Justice Helper"
local path_helper = getWorkingDirectory():gsub('\\','/') .. "/Justice_Helper.lua"
local path_settings = configDirectory .. "/Settings.json"
function load_settings()
    if not doesDirectoryExist(configDirectory) then
        createDirectory(configDirectory)
    end
    if not doesFileExist(path_settings) then
        settings = default_settings
		print('[Justice Helper] Файл с настройками не найден, использую стандартные настройки!')
    else
        local file = io.open(path_settings, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				settings = default_settings
				print('[Justice Helper] Не удалось открыть файл с настройками, использую стандартные настройки!')
			else
				local result, loaded = pcall(decodeJson, contents)
				if result then
					settings = loaded
					print('[Justice Helper] Настройки успешно загружены!')
					for category, _ in pairs(default_settings) do
						if settings[category] == nil then
							settings[category] = {}
						end
						for key, value in pairs(default_settings[category]) do
							if settings[category][key] == nil then
								settings[category][key] = value
							end
						end
					end
					if tostring(settings.general.version) ~= tostring(thisScript().version) then 
						settings.general.version = thisScript().version
					end
					save_settings()
				else
					print('[Justice Helper] Не удалось открыть файл с настройками, использую стандартные настройки!')
				end
			end
        else
            settings = default_settings
			print('[Justice Helper] Не удалось открыть файл с настройками, использую стандартные настройки!')
        end
    end
end
function save_settings()
    local file, errstr = io.open(path_settings, 'w')
    if file then
        local result, encoded = pcall(encodeJson, settings)
        file:write(result and encoded or "")
        file:close()
		print('[Justice Helper] Настройки сохранены!')
        return result
    else
        print('[Justice Helper] Не удалось сохранить настройки хелпера, ошибка: ', errstr)
        return false
    end
end
load_settings()
-------------------------------------------- JSON MY NOTES ---------------------------------------------
local notes = {
	note = {
		{ note_name = 'Зарплата', note_text = 'Почему ваша зарплата может быть меньше, чем указано:&- Если у вас нету жилья (дом/отель) то у вас будет -20 процентов зп&- Если у вас есть выговор то у вас будет -20 процентов зп&- Из-за фикса экономики (от разрабов) у вас будет -10 процентов зп&&Как повысить свою зарплату:&- Вступите в фулл семью с флагом чтобы иметь +7 процентов зп &( на 20 сервере это наша семья Martelli )&- Получите \"Военный билет\" чтобы иметь +15 процентов зп&- Купите охранника на \"зп фракции\" чтобы иметь до +25 процентов зп&- Повышайтесь на ранг повыше'},
		{ note_name = 'Тен-коды', note_text = '10-1 - Сбор всех офицеров на дежурстве.&10-2 - Вышел в патруль.&10-2R - Закончил патруль.&10-3 - Радиомолчание.&10-4 - Принято.&10-5 - Повторите.&10-6 - Не принято/неверно/нет.&10-7 - Ожидайте.&10-8 - Не доступен/занят.&10-14 - Запрос транспортировки.&10-15 - Подозреваемые арестованы.&10-18 - Требуется поддержка дополнительных юнитов.&10-20 - Локация.&10-21 - Статус и местонахождение.&10-22 - Выдвигайтесь к локации.&10-27 - Меняю маркировку патруля.&10-30 - Дорожно-транспортное происшествие.&10-40 - Большое скопление людей (более 4).&10-41 - Нелегальная активность.&10-46 - Провожу обыск.&10-55 - Траффик стоп.&10-57 VICTOR - Погоня за автомобилем.&10-57 FOXTROT - Пешая погоня.&10-66 - Траффик стоп повышенного риска.&10-70 - Запрос поддержки.&10-71 - Запрос медицинской поддержки.&10-88 - Теракт/ЧС.&10-99 - Ситуация урегулирована.&10-100 Временно недоступен для вызовов.' },
		{ note_name = 'Ситуационные коды', note_text = 'CODE 0 - Офицер ранен.&CODE 1 - Офицер в бедственном положении, нужна помощь всех юнитов.&CODE 2 - Обычный вызов [без сирен/стробоскопов/соблюдение ПДД].&CODE 2 HIGHT - Приоритетный вызов [без сирен/стробоскопов/соблюдение ПДД].&CODE 3 - Срочный вызов [сирены, стробоскопы, игнорирования ПДД].&CODE 4 - Стабильно, помощь не требуется.&Code 4 ADAM - Помощь не требуется, но офицеры поблизости должны быть готовы оказать помощь.&CODE 5 - Офицерам держаться подальше от опасного места.&CODE 6 - Задерживаюсь на месте [включая локацию и причину,например, 911].&CODE 7 - Перерыв на обед.&CODE 30 - Срабатывание "тихой" сигнализации на месте происшествия.&CODE 30 RINGER - Срабатывание "громкой сигнализации на месте происшествия.&CODE 37 - Обнаружение угнанного транспортного средства.&Сode TOM - Офицеру требуется Тайзер.' },
		{ note_name = 'Маркировки патруля', note_text = 'Основные:&ADAM [A] - Патруль из 2/3 офицеров на крузере.&LINCOLN [L] - Одиночный патруль на крузере.&MARY [M] - Одиночный патруль на мотоцикле.&HENRY [H] - Высокоскоростой патруль.&AIR [AIR] - Воздушный патруль.&Air Support Division [ASD] - Воздушная поддержка.&&Дополнительные:&CHARLIE [C] - Группа захвата.&ROBERT [R] - Отдел Детективов.&SUPERVISOR [SV] - Руководящий состав.&DAVID [D] - Cпециальный отдел SWAT.&EDWARD [E] - Эвакуатор полиции.&NORA [N] - немаркированная единица патруля.',},
	}
}
local path_notes = configDirectory .. "/Notes.json"
function load_notes()
	if doesFileExist(path_notes) then
		local file, errstr = io.open(path_notes, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				print('[Justice Helper] Не удалось открыть файл с заметками!')
				print('[Justice Helper] Причина: этот файл пустой')
			else
				local result, loaded = pcall(decodeJson, contents)
				if result then
					notes = loaded
					print('[Justice Helper] Заметки инициализированы!')
				else
					print('[Justice Helper] Не удалось открыть файл с заметками!')
					print('[Justice Helper] Причина: Не удалось декодировать json (ошибка в файле)')
				end
			end
        else
			print('[Justice Helper] Не удалось открыть файл с заметками!')
			print('[Justice Helper] Причина: ')
        end
	else
		print('[Justice Helper] Не удалось открыть файл с заметками!')
		print('[Justice Helper] Причина: этого файла нету в папке '..configDirectory)
	end
end
function save_notes()
    local file, errstr = io.open(path_notes, 'w')
    if file then
        local result, encoded = pcall(encodeJson, notes)
        file:write(result and encoded or "")
        file:close()
		print('[Justice Helper] Заметки сохранены!')
        return result
    else
        print('[Justice Helper] Не удалось сохранить заметки, ошибка: ', errstr)
        return false
    end
end
load_notes()
-------------------------------------------- JSON SMART UK ---------------------------------------------
local smart_uk = {}
local path_uk = configDirectory .. "/SmartUK.json"
function load_smart_uk()
	if doesFileExist(path_uk) then
		local file, errstr = io.open(path_uk, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				print('[Justice Helper] Не удалось открыть файл с умным розыском!')
				print('[Justice Helper] Причина: этот файл пустой')
			else
				local result, loaded = pcall(decodeJson, contents)
				if result then
					smart_uk = loaded
					print('[Justice Helper] Умный розыск инициализирован!')
				else
					print('[Justice Helper] Не удалось открыть файл с умным розыском!')
					print('[Justice Helper] Причина: Не удалось декодировать json (ошибка в файле)')
				end
			end
        else
			print('[Justice Helper] Не удалось открыть файл с умным розыском!')
			print('[Justice Helper] Причина: ')
        end
	else
		print('[Justice Helper] Не удалось открыть файл с умным розыском!')
		print('[Justice Helper] Причина: этого файла нету в папке '..configDirectory)
	end
end
function save_smart_uk()
    local file, errstr = io.open(path_uk, 'w')
    if file then
        local result, encoded = pcall(encodeJson, smart_uk)
        file:write(result and encoded or "")
        file:close()
		print('[Justice Helper] Умный розыск сохранён!')
        return result
    else
        print('[Justice Helper] Не удалось сохранить умный розыск, ошибка: ', errstr)
        return false
    end
end
load_smart_uk()
-------------------------------------------- JSON SMART PDD ---------------------------------------------
local smart_pdd = {}
local path_pdd = configDirectory .. "/SmartPDD.json"
function load_smart_pdd()
	if doesFileExist(path_pdd) then
		local file, errstr = io.open(path_pdd, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				print('[Justice Helper] Не удалось открыть файл с умным штрафом!')
				print('[Justice Helper] Причина: этот файл пустой')
			else
				local result, loaded = pcall(decodeJson, contents)
				if result then
					smart_pdd = loaded
					print('[Justice Helper] Умный штраф инициализирован!')
				else
					print('[Justice Helper] Не удалось открыть файл с умным штрафом!')
					print('[Justice Helper] Причина: Не удалось декодировать json (ошибка в файле)')
				end
			end
        else
			print('[Justice Helper] Не удалось открыть файл с умным штрафом!')
			print('[Justice Helper] Причина: ', errstr)
        end
	else
		print('[Justice Helper] Не удалось открыть файл с умным штрафом!')
		print('[Justice Helper] Причина: этого файла нету в папке '..configDirectory)
	end
end
function save_smart_pdd()
    local file, errstr = io.open(path_pdd, 'w')
    if file then
        local result, encoded = pcall(encodeJson, smart_pdd)
        file:write(result and encoded or "")
        file:close()
		print('[Justice Helper] Умные штрафы сохранены!')
        return result
    else
        print('[Justice Helper] Не удалось сохранить умные штрафы, ошибка: ', errstr)
        return false
    end
end
load_smart_pdd()
-------------------------------------------- JSON COMMANDS ---------------------------------------------
local commands = {
	commands = {
		{ cmd = '55', description = 'Проведение 10-55', text = '/r {my_doklad_nick} на CONTROL. Провожу 10-55 в районе {get_area} ({get_square}), СODE 4.&/m Водитель{get_storecar_model}, снизьте скорость и прижмитесь к обочине.&/m После остановки заглушите двигатель, держите руки на руле и не выходите из транспорта.&/m В случае неподчинения вы будете обьявлены в розыск, и по вам будет открыт огонь!', arg = '', enable = true, waiting = '1.200'},
		{ cmd = '66', description = 'Проведение 10-66', text = '/r {my_doklad_nick} на CONTROL. Провожу 10-66 в районе {get_area} ({get_square}), СODE 3!&/m Водитель{get_storecar_model}, немедленно прижмитесь к обочине и заглушите двигатель!&/m В случае неподчинения вы будете обьявлены в розыск, и по вам будет открыт огонь!', arg = '', enable = true, waiting = '1.200'},
		{ cmd = 'zd' , description = 'Привествие игрока' , text = 'Здраствуйте {get_ru_nick({arg_id})}&Я {my_ru_nick} - {fraction_rank} {fraction_tag}&Чем я могу Вам помочь?', arg = '{arg_id}' , enable = true , waiting = '1.200'},
		{ cmd = 'bk' , description = 'Запрос помощи с координатами' , text = '/r {my_doklad_nick} на CONTROL. Срочно нужна помощь, высылаю свои координаты. CODE 1&/me достаёт свой КПК и отправляет координаты в базу данных {fraction_tag}&/bk 10-20', arg = '' , enable = true , waiting = '1.200'},
		{ cmd = 'take' , description = 'Изьятие предметов игрока' , text = '/do В подсумке находиться небольшой зип-пакет.&/me достаёт из подсумка зип-пакет и отрывает его&/me кладёт в зип-пакет изьятые предметы задержанного человека&/take {arg_id}&/do Изьятые предметы в зип-пакете.&/todo Отлично*убирая зип-пакет в подсумок', arg = '{arg_id}' , enable = true , waiting = '1.200' },
        { cmd = 'cure' , description = 'Поднять игрока из стадии' ,  text = '/me наклоняется над человеком, и прощупывает его пульс на сонной артерии&/cure {arg_id}&/do Пульс отсутствует.&/me начинает делать человеку непрямой массаж сердца, время от времени проверяя пульс&/do Спустя несколько минут сердце человека началось биться.&/do Человек пришел в сознание.&/todo Отлично*улыбаясь' , arg = '{arg_id}' , enable = true , waiting = '1.200'  },
		{ cmd = 'time' , description = 'Посмотреть время' ,  text = '/me взглянул{sex} на свои часы с гравировкой MTG MODS и посмотрел{sex} время&/time&/do На часах видно время {get_time}.' , arg = '' , enable = true, waiting = '1.200'  },
        { cmd = 'pas' , description = 'Запросить документы (PD)' ,  text = 'Здраствуйте, управление {fraction_tag}, я {fraction_rank} {my_ru_nick}&/do Cлева на груди жетон полицейского, справа именная нашивка с именем.&/me  достаёт своё удостоверение из кармана&/showbadge {arg_id}&Прошу предъявить документ, удостоверяющий вашу личность.&/n {get_nick({arg_id})}, введите /showpass {my_id}' , arg = '{arg_id}' , enable = true , waiting = '1.200'  },
        { cmd = 'doc' , description = 'Запросить документы (FBI)' ,  text = 'Здраствуйте, я {fraction_rank} ФБР&/do Cлева на груди спец-жетон ФБР.&/me указывает пальцем на свой спец-жетон на груди&Прошу предъявить документ, удостоверяющий вашу личность.&/n {get_nick({arg_id})}, введите /showpass {my_id} или /showbadge {my_id}' , arg = '{arg_id}' , enable = false , waiting = '1.200'  },
        { cmd = 'ts' , description = 'Выписать штраф' ,  text = '/do Бланк протокола и ручка находяться в нагрудном кармане.&/me достаёт из нагрудного кармана бланк протокола и ручку.&/me вписывает в бланк данные нарушителя&/writeticket {arg_id} {arg2}&/do Бланк протокола заполнен.&/me передаёт бланк со штрафом нарушителю для дальнейшей оплаты' , arg = '{arg_id} {arg2}' , enable = true, waiting = '1.200'  },
        { cmd = 'pr' , description = 'Погоня' ,  text = '/pursuit {arg_id}' , arg = '{arg_id}' , enable = true, waiting = '1.200'  },
        { cmd = 'su' , description = 'Выдать розыск' ,  text = '/me достаёт свой КПК и открывает базу данных преступников&/me вносит изменения в базу данных преступинков&/do Преступник занесён в базу данных преступников.&/su {arg_id} {arg2} {arg3}&/z {arg_id}' , arg = '{arg_id} {arg2} {arg3}' , enable = true, waiting = '1.200'  },
        { cmd = 'fsu' , description = 'Запросить выдачу розыска' ,  text = '/do Рация на тактическом поясе.&/me достаёт рацию и связавается с диспетчером&/me передаёт диспетчеру запрос на внесение человека в базу данных преступников&/r {my_doklad_nick} на CONTROL.&/r Прошу обьявить в розыск {arg2} степени дело N{arg_id}. Причина: {arg3}' , arg = '{arg_id} {arg2} {arg3}' , enable = true, waiting = '1.200'  },
		{ cmd = 'givefsu' , description = 'Выдача розыска по запросу офицера' ,  text = '/do Рация на тактическом поясе.&/me достаёт рацию и связавается с офицером для уточнения данных&/r 10-4, выдаю розыск по запросу офицера {get_rp_nick({arg_id})}!&/me достаёт свой КПК и открывает базу данных преступников&/me вносит изменения в базу данных преступинков&/do Преступник занесён в базу данных преступиков.&/su {get_form_su} (по запросу офицера {get_rp_nick({arg_id})})&' , arg = '{arg_id}' , enable = true, waiting = '1.200'  },
		{ cmd = 'unsu' , description = 'Понизить розыск' ,  text = '/me достаёт свой КПК и открывает базу данных преступников&/me ищёт дело N{arg_id} и вносит изменения в базу данных преступинков&/unsu {arg_id} {arg2} {arg3}&/do Преступику понижен степень розыска.' , arg = '{arg_id} {arg2} {arg3}' , enable = true, waiting = '1.200'  },
		{ cmd = 'clear' , description = 'Снять розыск' ,  text = '/me достаёт свой КПК и открывает базу данных преступников&/me ищёт дело N{arg_id} и вносит изменения в базу данных преступинков&/clear {arg_id}&/do Дело N{arg_id} больше не находится в списке разыскиваемых преступников.' , arg = '{arg_id}' , enable = true, waiting = '1.200'  },
        { cmd = 'cuff' , description = 'Надеть наручники' ,  text = '/do Наручники на тактическом поясе.&/me снимает наручники с пояса и надевает их на задержанного&/cuff {arg_id}&/do Задержанный в наручниках.' , arg = '{arg_id}' , enable = true , waiting = '1.200'},
        { cmd = 'uncuff' , description = 'Снять наручники' ,  text = '/do На тактическом поясе прикреплены ключи от наручников.&/me снимает с пояса ключ от наручников и вставляет их в наручники задержанного&/me прокручивает ключ в наручниках и снимает их с задержанного&&/uncuff {arg_id}&/do Наручники сняты с задержанного&/me кладёт ключ и наручники обратно на тактический пояс', arg = '{arg_id}', enable = true, waiting = '1.200'},
        { cmd = 'gtm' , description = 'Повести за собой' ,  text = '/me схватывает задержанного за руки и ведёт его за собой&/gotome {arg_id}&/do Задержанный идёт в конвое.', arg = '{arg_id}', enable = true, waiting = '1.200'},
        { cmd = 'ungtm' , description = 'Перестать вести за собой' ,  text = '/me отпускает руки задержанного и перестаёт вести его за собой&/ungotome {arg_id}', arg = '{arg_id}', enable = true, waiting = '1.200'},
		{ cmd = 'ss' , description = 'Кричалка' ,  text = '/s Всем поднять руки вверх, работает {fraction_tag}!', arg = '', enable = true, waiting = '1.200'},
		{ cmd = 't' , description = 'Достать тазер' ,  text = '/taser', arg = '', enable = true, waiting = '1.200'},
		{ cmd = 'frl' , description = 'Первичный обыск' ,  text = 'Сейчас я проверю у вас наличие оружия или других острых предметов, не двигайтесь.&/me прощупывает тело задержанного человека&/me прощупывает карманы задержанного человека', arg = '', enable = false, waiting = '1.200'},
		{ cmd = 'fr' , description = 'Полный обыск' ,  text = '/do Резиновые перчатки на тактическом поясе.&/todo Сейчас я полностю обыщу вас, на наличие запрещенных предметов*надевая резиновые перчатки&/me прощупывает тело и карманы задержанного человека&/me достаёт из карманов задержанного все его вещи для изучения&/me внимательно осматривает все найденные вещи у задержанного человека&/frisk {arg_id}&/me снимает резиновые перчатки и убирает их на тактический пояск&/do Блокнот с ручкой в нагрудном кармане.&/me берет в руки блокнот с ручкой, и записывает всю информацию про обыск&/me сделал пометки, убирает блокнот с ручкой в нагрудный карман', arg = '{arg_id}', enable = true, waiting = '1.200'},
		{ cmd = 'camon' , description = 'Включить cкрытую боди камеру' ,  text = '/do К форме прикреплена скрытая боди камера.&/me незаметным движением руки включил{sex} боди камеру.&/do Скрытая боди камера включена и снимает всё происходящее.', arg = '', enable = true, waiting = '1.200'},
		{ cmd = 'camoff' , description = 'Выключить cкрытую боди камеру' ,  text = '/do К форме прикреплена скрытая боди камера.&/me незаметным движением руки выключил{sex} боди камеру.&/do Скрытая боди камера выключена и больше не снимает всё происходящее.', arg = '', enable = true, waiting = '1.200'},
		{ cmd = 'inc' , description = 'Затащить в транспорт' ,  text = '/me открывает заднюю дверь транспорта&/todo Наклоните голову, здесь дверь*затаскивая задержанного в транспортное средство&/incar {arg_id} {arg2}&/me закрывает заднюю дверь транспорта&/do Задержанный в транспортном средстве.', arg = '{arg_id} {arg2}', enable = true, waiting = '1.200'},
		{ cmd = 'ej' , description = 'Выбросить из транспорта',  text = '/me открывает дверь транспорта&/me помогает человеку выйти из транспорта&/eject {arg_id}&/me закрывает дверь транспорта', arg = '{arg_id}', enable = true, waiting = '1.200'},	
		{ cmd = 'pl' , description = 'Выбросить игрока из его транспорта',  text = '/me резким ударом дубинки разбивает стело транспорта задержанного&/pull {arg_id}&/me выбрасывает задержанного из его транспорта и ударом дубинки оглушает его', arg = '{arg_id}', enable = true, waiting = '1.200'},	
		{ cmd = 'mr' , description = 'Зачитать правило Миранды',  text = 'Вы имеете право хранить молчание.&Всё, что вы скажете, может и будет использовано против вас в суде.&Вы имеете право на 1 телефонный звонок, например для вызова частного адвоката.&Ваш адвокат может присутствовать при допросе.&Если вы не можете оплатить услуги адвоката, он будет предоставлен вам государством.&Вам ясны Ваши права?', arg = '', enable = true, waiting = '1.200'},	
		{ cmd = 'unmask' , description = 'Снять балаклаву с игрока',  text = '/do Задержанный в балаклаве.&/me стягивает балаклаву с головы задеражнного&/unmask {arg_id}', arg = '{arg_id}', enable = true, waiting = '1.200'},
		{ cmd = 'arr' , description = 'Арестовать (в участке)',  text = '/me включает свой бортовой компютер и вводит код доступа сотрудника&/me заходит в раздел оформления протоколов задержаний и указывает данные&/do Протокол задержания заполнен.&/me вызывает по рации дежурный наряд участка и передаёт им задержанного человека&/arrest', arg = '', enable = true, waiting = '1.200'},
		{ cmd = 'drugs' , description = 'Провести Drugs Test' ,  text = '/do На тактическом поясе прикреплён подсумок.&/me открывает подсумок и достаёт из него набор Drugs Test&/me берёт из набора пробирку с этиловым спиром&/me засыпает найденное вещество в пробирку&/me достаёт из подсумка тест Имуно-Хром-10 и добавляет его в пробирку&/do В пробирке с этиловым спиртом находится неизвестное вещество и Имуно-Хром-10.&/me акуратными движениями взбалтывает пробирку&/do От теста Имуно-Хром-10 содержимое пробирки сменило цвет.&/todo Да, это точно наркотики*увидев что содержимое пробирки сменило цвет&/me убирает пробирку обратно в подсумок и закрывает его', arg = '', enable = true, waiting = '1.200'},
		{ cmd = 'rbomb' , description = 'Деактивировать бомбу' ,  text = '/do На тактическом поясе прикреплён сапёрный набор.&/me снимает с пояса сапёрный набор и кладет его на землю, затем открывает его&/do Открытый сапёрный набор находится на земле.&/me достаёт из сапёрного набора пакет с жидким азотом и кладет его на землю&/me достаёт из сапёрного набора отвёртку&/do Отвертка в руках, а пакет с жидким азотом на земле.&/do На корпусе бомбы находится 2 болтика.&/me откручивает болтики с бомбы и убирает их вместе с отвёрткой в сторону&/me акуратным движением руки вскрывает крышку бомбы&/me внимательно осматривает бомбу&/do Внутри бомбы видна детонирующая часть.&/me достаёт из сапёрного набора кусачки&/do Кусачки в руках.&/me акуратным движением кусочок разрезает красный провод бомбы&/do Таймер остановился, тиканье со стороны бомбы не слышно.&/me берёт в руки охлаждающий пакет с жидким азотом и кладёт его детонирующую часть бомбы&/removebomb&/do Бомба обезврежена.&/me убирает кусачки и отвёртку обратно в саперный набор и закрывает его', arg = '', enable = true, waiting = '1.200'},
		{ cmd = 'delo' , description = 'Расследование убийства' ,  text = '/do Сотрудник прибыл на место убийства.&/todo Такс, что же здесь произошло*осматривая место убийства&/me осматривает и  изучает все улики&{pause}&/me достаёт из подсумка бланк для расследования и ручку&/me заполняет бланк расследования записывая все изученные улики&{pause}&/me записывает в бланк точную дату и время убийства&{pause}&/do Найдено орудие убийства.&/me записывает в бланк орудие убийства&{pause}&/do Бланк расследования убийства полностю заполнен.&/todo Отлично, расследование окончено*убирая бланк в карман', arg = '', enable = true, waiting = '1.200'},
		{ cmd = 'dismiss' , description = 'Увольнение (для 6+ ФБР)' ,  text = '/do КПК находиться на поясном держателе.&/me берёт в руки свой КПК и включает его&/me заходит в базу данных {fraction_tag} и переходит в раздел ', arg = '{arg_id} {arg2}', enable = false, waiting = '1.200'},
	},
	commands_manage = {
		{ cmd = 'book' , description = 'Выдача игроку трудовой книги' , text = 'Оказывается у вас нету трудовой книги, но не переживайте!&Сейчас я вам выдам её, вам не нужно никуда ехать, секунду...&/me достаёт из своего кармана новую трудовую книжку и ставит на ней печать {fraction_tag}&/todo Берите*передавая трудовую книгу челоку напротив&/givewbook {arg_id} 100&/n {get_nick({arg_id})}, примите предложение в /offer чтобы получить трудовую книгу!' , arg = '{arg_id}', enable = true, waiting = '1.200'  },
		{ cmd = 'inv' , description = 'Принятие игрока в фракцию' , text = '/do В кармане есть связка с ключами от раздевалки.&/me достаёт из кармана один ключ из связки ключей от раздевалки&/todo Возьмите, это ключ от нашей раздевалки*передавая ключ человеку напротив&/invite {arg_id}' , arg = '{arg_id}', enable = true, waiting = '1.200'   },
		{ cmd = 'rp' , description = 'Выдача сотруднику /fractionrp' , text = '/fractionrp {arg_id}' , arg = '{arg_id}', enable = true, waiting = '1.200'  },
		{ cmd = 'gr' , description = 'Повышение/понижение cотрудника' , text = '{show_rank_menu}&/me достаёт из кармана свой телефон и заходит в базу данных {fraction_tag}&/me изменяет информацию о сотруднике {get_ru_nick({arg_id})} в базе данных {fraction_tag}&/me выходит с базы данных и убирает телефон обратно в карман&/giverank {arg_id} {get_rank}&/r Сотрудник {get_ru_nick({arg_id})} получил новую должность!' , arg = '{arg_id}', enable = true, waiting = '1.200'  },
		{ cmd = 'vize' , description = 'Управление Vice City визой сотрудника' , text = '/me достаёт из кармана свой телефон и заходит в базу данных {fraction_tag}&/me изменяет информацию о сотруднике {get_ru_nick({arg_id})} в базе данных {fraction_tag}&/me выходит с базы данных и убирает телефон обратно в карман&{lmenu_vc_vize}' , arg = '{arg_id}', enable = true, waiting = '1.200'   },
		{ cmd = 'cjob' , description = 'Посмотреть успешность сотрудника' , text = '/checkjobprogress {arg_id}' , arg = '{arg_id}', enable = true, waiting = '1.200'   },	
		{ cmd = 'fmutes' , description = 'Выдать мут сотруднику (10 min)' , text = '/fmutes {arg_id} Н.У.&/r Сотрудник {get_ru_nick({arg_id})} лишился права использовать рацию на 10 минут!' , arg = '{arg_id}', enable = true, waiting = '1.200'   },
		{ cmd = 'funmute' , description = 'Снять мут сотруднику' , text = '/funmute {arg_id}&/r Сотрудник {get_ru_nick({arg_id})} теперь может пользоваться рацией!' , arg = '{arg_id}', enable = true, waiting = '1.200'   },
		{ cmd = 'vig' , description = 'Выдача выговора cотруднику' , text = '/me достаёт из кармана свой телефон и заходит в базу данных {fraction_tag}&/me изменяет информацию о сотруднике {get_ru_nick({arg_id})} в базе данных {fraction_tag}&/me выходит с базы данных и убирает телефон обратно в карман&/fwarn {arg_id} {arg2}&/r Сотруднику {get_ru_nick({arg_id})} выдан выговор! Причина: {arg2}' , arg = '{arg_id} {arg2}', enable = true, waiting = '1.200'   },
		{ cmd = 'unvig' , description = 'Снятие выговора cотруднику' , text = '/me достаёт из кармана свой телефон и заходит в базу данных {fraction_tag}&/me изменяет информацию о сотруднике {get_ru_nick({arg_id})} в базе данных {fraction_tag}&/me выходит с базы данных и убирает телефон обратно в карман&/unfwarn {arg_id}&/r Сотруднику {get_ru_nick({arg_id})} был снят выговор!' , arg = '{arg_id}', enable = true, waiting = '1.200'   },
		{ cmd = 'unv' , description = 'Увольнение игрока из фракции' , text = '/me достаёт из кармана свой телефон и заходит в базу данных {fraction_tag}&/me изменяет информацию о сотруднике {get_ru_nick({arg_id})} в базе данных {fraction_tag}&/me выходит с базы данных и убирает свой телефон обратно в карман&/uninvite {arg_id} {arg2}&/r Сотрудник {get_ru_nick({arg_id})} был уволен по причине: {arg2}' , arg = '{arg_id} {arg2}', enable = true, waiting = '1.200'   },
		{ cmd = 'point' , description = 'Установить метку для сотрудников' , text = '/r Срочно выдвигайтесь ко мне, отправляю вам координаты...&/point' , arg = '', enable = true, waiting = '1.200'  },
	}
}
local path_commands = configDirectory .. "/Commands.json"
function load_commands()
	if doesFileExist(path_commands) then
		local file, errstr = io.open(path_commands, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				print('[Justice Helper] Не удалось открыть файл с командами!')
				print('[Justice Helper] Причина: этот файл пустой')
			else
				local result, loaded = pcall(decodeJson, contents)
				if result then
					commands = loaded
					print('[Justice Helper] Все команды инициализирован!')
				else
					print('[Justice Helper] Не удалось открыть файл с командами!')
					print('[Justice Helper] Причина: Не удалось декодировать json (ошибка в файле)')
				end
			end
        else
			print('[Justice Helper] Не удалось открыть файл с командами!')
			print('[Justice Helper] Причина: ', errstr)
        end
	else
		print('[Justice Helper] Не удалось открыть файл с командами!')
		print('[Justice Helper] Причина: этого файла нету в папке '..configDirectory)
		print('[Justice Helper] Инициализация стандартных команд...')
		save_commands()
		load_commands()
	end
end
function save_commands()
    local file, errstr = io.open(path_commands, 'w')
    if file then
        local result, encoded = pcall(encodeJson, commands)
        file:write(result and encoded or "")
        file:close()
		print('[Justice Helper] Ваши команды сохранены!')
        return result
    else
        print('[Justice Helper] Не удалось сохранить команды хелпера, ошибка: ', errstr)
        return false
    end
end
load_commands()
-------------------------------------------- JSON ARZ VEHICLES ---------------------------------------------
local path_arzvehicles = configDirectory .. "/VehiclesArizona.json"
local arzvehicles = {}
function load_arzvehicles()
	if doesFileExist(path_arzvehicles) then
		local file, errstr = io.open(path_arzvehicles, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				print('[Justice Helper] Не удалось открыть файл с моделями каров аризоны!')
				print('[Justice Helper] Причина: этот файл пустой')
			else
				local result, loaded = pcall(decodeJson, contents)
				if result then
					arzvehicles = loaded
					print('[Justice Helper] Модели кастом каров аризоны инициализированы!')
				else
					print('[Justice Helper] Не удалось открыть файл с моделями каров аризоны!')
					print('[Justice Helper] Причина: Не удалось декодировать json (ошибка в файле)')
				end
			end
        else
			print('[Justice Helper] Не удалось открыть файл с моделями каров аризоны!')
			print('[Justice Helper] Причина: ', errstr)
        end
	else
		print('[Justice Helper] Не удалось открыть файл с моделями каров аризоны!')
		print('[Justice Helper] Причина: этого файла нету в папке ' .. configDirectory)
	end
end
load_arzvehicles()
------------------------------------------- MonetLoader --------------------------------------------------
function isMonetLoader() return MONET_VERSION ~= nil end
if isMonetLoader() then
	gta = ffi.load('GTASA') 
	ffi.cdef[[ void _Z12AND_OpenLinkPKc(const char* link); ]] -- функция для открытия ссылок
end
if MONET_DPI_SCALE == nil then MONET_DPI_SCALE = 1.0 end
---------------------------------------------- Mimgui -----------------------------------------------------
local imgui = require('mimgui')
local fa = require('fAwesome6_solid')
local sizeX, sizeY = getScreenResolution()

local MainWindow = imgui.new.bool()
local checkboxone = imgui.new.bool(false)
local checkbox_accent_enable = imgui.new.bool(settings.general.accent_enable or false)
local checkbox_patrool_autodoklad =  imgui.new.bool(settings.general.auto_doklad_patrool or false)
local checkbox_autodoklad_damage =  imgui.new.bool(settings.general.auto_doklad_damage or false)
local checkbox_autodoklad_arrest =  imgui.new.bool(settings.general.auto_doklad_arrest or false)
local checkbox_automask =  imgui.new.bool(settings.general.auto_mask or false)
local checkbox_change_code_siren = imgui.new.bool(settings.general.auto_change_code_siren or false)
local checkbox_update_members = imgui.new.bool(settings.general.auto_update_members or false)
local checkbox_update_wanteds = imgui.new.bool(settings.general.auto_update_wanteds or false)
local checkbox_notify_port = imgui.new.bool(settings.general.auto_notify_port or false)
local checkbox_notify_payday = imgui.new.bool(settings.general.auto_notify_payday or false)
local checkbox_auto_clicker = imgui.new.bool(settings.general.auto_clicker_situation or false)

local input_accent = imgui.new.char[256](u8(settings.player_info.accent))
local input_name_surname = imgui.new.char[256](u8(settings.player_info.name_surname))
local input_fraction_tag = imgui.new.char[256](u8(settings.player_info.fraction_tag))
local theme = imgui.new.int(0)
local fastmenu_type = imgui.new.int(settings.general.mobile_fastmenu_button and 1 or 0)
local stop_type = imgui.new.int(settings.general.mobile_stop_button and 1 or 0)


local DeportamentWindow = imgui.new.bool()
local input_dep_fm = imgui.new.char[32](u8(settings.deportament.dep_fm))
local input_dep_text = imgui.new.char[256]()
local input_dep_tag1 = imgui.new.char[32](u8(settings.deportament.dep_tag1))
local input_dep_tag2 = imgui.new.char[32](u8(settings.deportament.dep_tag2))
local input_dep_new_tag = imgui.new.char[32]()

local MembersWindow = imgui.new.bool()
local members = {}
local members_new = {}
local members_check = false
local members_fraction = nil
local update_members_check = false

local WantedWindow = imgui.new.bool()
local wanted = {}
local wanted_new = {}
local check_wanted = false
local update_wanted_check = false

local GiveRankMenu = imgui.new.bool()
local giverank = imgui.new.int(5)

local SobesMenu = imgui.new.bool()
local DoprosMenu = imgui.new.bool()

local PatroolMenu = imgui.new.bool()
local PatroolInfoMenu = imgui.new.bool()
local patrool_start_time = 0
local patrool_current_time = 0
local patrool_time = 0
local patrool_code = 'CODE 4'
local patrool_mark = 'ADAM'
local patrool_active = false
local ComboPatroolMark = imgui.new.int(0)
local combo_patrool_mark_list = {'ADAM', 'LINCOLN', 'MARY', 'HENRY', 'AIR', 'ASD', 'CHARLIE', 'ROBERT', 'SUPERVISOR', 'DAVID', 'EDWARD', 'NORA'}
local ImItemsPatroolMark = imgui.new['const char*'][#combo_patrool_mark_list](combo_patrool_mark_list)
local ComboPatroolCode = imgui.new.int(5)
local combo_patrool_code_list = {'CODE 0', 'CODE 1', 'CODE 2', 'CODE 2 HIGHT', 'CODE 3', 'CODE 4', 'CODE 4 ADAM', 'CODE 5', 'CODE 6', 'CODE 7', 'CODE 30', 'CODE 30 RINGER', 'CODE 37', 'CODE TOM'}
local ImItemsPatroolCode = imgui.new['const char*'][#combo_patrool_code_list](combo_patrool_code_list)

local SumMenuWindow = imgui.new.bool()
local input_sum = imgui.new.char[128]()
local checkbox_sum = imgui.new.bool(settings.general.use_form_su)
local form_su = ''

local TsmMenuWindow = imgui.new.bool()
local input_tsm = imgui.new.char[128]()

local CommandStopWindow = imgui.new.bool()
local CommandPauseWindow = imgui.new.bool()

local LeaderFastMenu = imgui.new.bool()
local FastMenu = imgui.new.bool()
local FastPieMenu = imgui.new.bool()
local FastMenuButton = imgui.new.bool()
local FastMenuPlayers = imgui.new.bool()

local NoteWindow = imgui.new.bool()
local show_note_name = nil
local show_note_text = nil

local InformationWindow = imgui.new.bool()
local Information1Window = imgui.new.bool()

local UpdateWindow = imgui.new.bool()
local updateUrl = ""
local updateVer = ""
local updateInfoText = ""
local need_update_helper = false
local download_helper = false
local download_smartuk = false
local download_smartpdd = false
local download_arzvehicles = false

local BinderWindow = imgui.new.bool()
local waiting_slider = imgui.new.float(0)
local ComboTags = imgui.new.int()
local item_list = {u8'Без аргумента', u8'{arg} - принимает любой аргумент', u8'{arg_id} - принимает только аргумент ID игрока', u8'{arg_id} {arg2} - принимает 2 аругмента: ID игрока и любой аргумент', u8'{arg_id} {arg2} {arg3} - принимает 3 аргумента: ID игрока, одну цифру, и любой аргумент'}
local ImItems = imgui.new['const char*'][#item_list](item_list)
local change_waiting = nil
local change_cmd_bool = false
local change_cmd = nil
local change_description = nil
local change_text = nil
local change_arg = nil
local binder_create_command_9_10 = false
local tagReplacements = {
	my_id = function() return select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) end,
    my_nick = function() return sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) end,
    my_rp_nick = function() return sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_',' ') end,
    my_doklad_nick = function() 
        local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
        if nick:find('(.+)%_(.+)') then
			local name, surname = nick:match('(.+)%_(.+)')
			return name:sub(1, 1)  .. '.' .. surname
		else
			return nick
		end
    end,
	my_ru_nick = function() return TranslateNick(settings.player_info.name_surname) end,
	fraction_rank_number = function() return settings.player_info.fraction_rank_number end,
	fraction_rank = function() return settings.player_info.fraction_rank end,
	fraction_tag = function() return settings.player_info.fraction_tag end,
	fraction = function() return settings.player_info.fraction end,
	sex = function() 
		if settings.player_info.sex == 'Женщина' then
			local temp = 'а'
			return temp
		else
			return ''
		end
	end,
	get_time = function ()
		return os.date("%H:%M:%S")
	end,
	get_rank = function ()
		return giverank[0]
	end,
	get_square = function ()
		return kvadrat()
	end,
	get_area = function ()
		local x,y,z = getCharCoordinates(PLAYER_PED)
		return calculateZoneRu(x,y,z)
	end,
	get_city = function ()
		local city = {
			[0] = "Вне города",
			[1] = "Лос Сантос",
			[2] = "Сан Фиерро",
			[3] = "Лас Вентурас"
		}
		return city[getCityPlayerIsIn(PLAYER_PED)]
	end,
	get_storecar_model = function ()
		local closest_car = nil
		local closest_distance = 75
		local my_pos = {getCharCoordinates(PLAYER_PED)}
		local my_car
		if isCharInAnyCar(PLAYER_PED) then
			my_car = storeCarCharIsInNoSave(PLAYER_PED)
		end
		for _, vehicle in ipairs(getAllVehicles()) do
			if doesCharExist(getDriverOfCar(vehicle)) and vehicle ~= my_car then
				local vehicle_pos = {getCarCoordinates(vehicle)}
				local distance = getDistanceBetweenCoords3d(my_pos[1], my_pos[2], my_pos[3], vehicle_pos[1], vehicle_pos[2], vehicle_pos[3])
				if distance < closest_distance and vehicle ~= my_car then
					--sampAddChatMessage(math.floor(distance),-1)
					closest_distance = distance
					closest_car = vehicle
				end
				--sampAddChatMessage(select(2, sampGetPlayerIdByCharHandle(getDriverOfCar(vehicle))), 0x009EFF)
			end
		end
		if closest_car then
			return " " .. getNameOfARZVehicleModel(getCarModel(closest_car))
		else
			sampAddChatMessage("[Justice Helper] {ffffff}Не удалось получить модель ближайшего транспорта!", 0x009EFF)
			return ''
		end
	end,
	get_form_su = function ()
		return form_su
	end,
	get_patrool_time = function ()
		local hours = math.floor(patrool_time / 3600)
		local minutes = math.floor(( patrool_time % 3600) / 60)
		local secs = patrool_time % 60
		if hours > 0 then
			return string.format("%02d:%02d:%02d", hours, minutes, secs)
		else
			return string.format("%02d:%02d", minutes, secs)
		end
	end,
	get_patrool_code = function ()
		return patrool_code
	end,
	get_patrool_mark = function ()
		return patrool_mark .. '-' .. select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
	end,
	get_car_units = function ()
		if isCharInAnyCar(PLAYER_PED) then
			local car = storeCarCharIsInNoSave(PLAYER_PED)
			local success, passengers = getNumberOfPassengers(car)
			if success and passengers and tonumber(passengers) > 0 then
				local my_passengers = {}
				for k, v in ipairs(getAllChars()) do
					local res, id = sampGetPlayerIdByCharHandle(v)
					if res and id ~= select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
						if isCharInAnyCar(v) then
							if car == storeCarCharIsInNoSave(v) then
								table.insert(my_passengers, id)
							end
						end
					end
				end
				if #my_passengers ~= 0 then
					local units = ''
					for k, idd in ipairs(my_passengers) do
						local nickname = sampGetPlayerNickname(idd)
						local first_letter = nickname:sub(1, 1)
						local last_name = nickname:match(".*_(.*)")
						if last_name then
							units = units .. first_letter .. "." .. last_name .. ' '
						else
							units = units .. nickname .. ' ' -- В случае, если нет подчеркивания
						end
					end
					return units
				else
					--sampAddChatMessage('[Justice Helper] В вашем авто нету ваших напарников!')
					return 'Нету'
				end
			else
				--sampAddChatMessage('[Justice Helper] В вашем авто нету ваших напарников!')
				return 'Нету'
			end
		else
			--sampAddChatMessage('[Justice Helper] Вы не находитесь в авто, невозможно получить ваших напарников!')
			return 'Нету'
		end
	end
}
local binder_tags_text = [[
{my_id} - Ваш ID
{my_nick} - Ваш Никнейм 
{my_rp_nick} - Ваш Никнейм без _
{my_ru_nick} - Ваше Имя и Фамилия
{my_doklad_nick} - Первая буква вашего имени и фамилия

{fraction} - Ваша фракция
{fraction_rank} - Ваша фракционная должность
{fraction_tag} - Тэг вашей фракции

{sex} - Добавляет букву "а" если в хелпере указан женский пол

{get_time} - Получить текущее время
{get_city} - Получить текущий город
{get_square} - Получить текущий квадрат
{get_area} - Получить текущий район
{get_storecar_model} - Получить модель ближайшего к вам авто с водителем

{get_nick({arg_id})} - получить Никнейм из аргумента ID игрока
{get_rp_nick({arg_id})} - получить Никнейм без символа _ из аргумента ID игрока
{get_ru_nick({arg_id})} - получить Никнейм на кирилице из аргумента ID игрока 
]]
local binder_tags_text2 = [[
{show_deportament_menu} - Открыть меню рации депортамента

{lmenu_vc_vize} - Авто-выдача визы Vice City

{give_platoon} - Назначить взвод игроку

{open_mimgui_members} - Открыть Mimgui Members

{show_rank_menu} - Открыть меню выдачи рангов
{get_rank} - Получить выбранный ранг

{pause} - Поставить команду на паузу и ожидать нажатия
]]
-------------------------------------------- MoonMonet ----------------------------------------------------

local monet_no_errors, moon_monet = pcall(require, 'MoonMonet') -- безопасно подключаем библиотеку

local message_color = 0x009EFF
local message_color_hex = '{009EFF}'

if settings.general.moonmonet_theme_enable and monet_no_errors then
	function rgbToHex(rgb)
		local r = bit.band(bit.rshift(rgb, 16), 0xFF)
		local g = bit.band(bit.rshift(rgb, 8), 0xFF)
		local b = bit.band(rgb, 0xFF)
		local hex = string.format("%02X%02X%02X", r, g, b)
		return hex
	end
	message_color = settings.general.moonmonet_theme_color
	message_color_hex = '{' ..  rgbToHex(settings.general.moonmonet_theme_color) .. '}'
   
	theme[0] = 1
else
	theme[0] = 0
end
local tmp = imgui.ColorConvertU32ToFloat4(settings.general.moonmonet_theme_color)
local mmcolor = imgui.new.float[3](tmp.z, tmp.y, tmp.x)

------------------------------------------- Mimgui Hotkey  -----------------------------------------------------
if not isMonetLoader() then
	hotkey_no_errors, hotkey = pcall(require, 'mimgui_hotkeys')
	if hotkey_no_errors then
		hotkey.Text.NoKey = u8'< nil >'
		hotkey.Text.WaitForKey = u8'< wait >'
		MainMenuHotKey = hotkey.RegisterHotKey('Open MainMenu', false, decodeJson(settings.general.bind_mainmenu), function()
			if settings.general.use_binds then 
				if not MainWindow[0] then
					MainWindow[0] = true
				end
			end
		end)
		FastMenuHotKey = hotkey.RegisterHotKey('Open FastMenu', false, decodeJson(settings.general.bind_fastmenu), function() 
			if settings.general.use_binds then 
				local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
				if valid and doesCharExist(ped) then
					local result, id = sampGetPlayerIdByCharHandle(ped)
					if result and id ~= -1 and not LeaderFastMenu[0] then
						show_fast_menu(id)
					end
				end
			end
		end)
		LeaderFastMenuHotKey = hotkey.RegisterHotKey('Open LeaderFastMenu', false, decodeJson(settings.general.bind_leader_fastmenu), function() 
			if settings.general.use_binds then 
				if tonumber(settings.player_info.fraction_rank_number) >= 9 then 
					local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
					if valid and doesCharExist(ped) then
						local result, id = sampGetPlayerIdByCharHandle(ped)
						if result and id ~= -1 and not FastMenu[0] then
							show_leader_fast_menu(id)
						end
					end
				end
			end
		end)
		
		CommandStopHotKey = hotkey.RegisterHotKey('Stop Command', false, decodeJson(settings.general.bind_command_stop), function() 
			if settings.general.use_binds then 
				sampProcessChatInput('/stop')
			end
		end)
		function getNameKeysFrom(keys)
			local keys = decodeJson(keys)
			local keysStr = {}
			for _, keyId in ipairs(keys) do
				local keyName = require('vkeys').id_to_name(keyId) or ''
				table.insert(keysStr, keyName)
			end
			return tostring(table.concat(keysStr, ' + '))
		end
		addEventHandler('onWindowMessage', function(msg, key, lparam)
			if msg == 641 or msg == 642 or lparam == -1073741809 then  hotkey.ActiveKeys = {} end
			if msg == 0x0005 then hotkey.ActiveKeys = {} end
		end)
	end
end
------------------------------------------------- Other --------------------------------------------------------
local PlayerID = nil
local player_id = nil
local check_stats = false
local anti_flood_auto_uval = false
local spawncar_bool = false

local vc_vize_bool = false
local vc_vize_player_id = nil

local godeath_player_id = nil
local godeath_locate = ''
local godeath_city = ''

local clicked = false

local message1
local message2
local message3

local isActiveCommand = false

local debug_mode = false

local command_stop = false
local command_pause = false

local auto_uval_checker = false

local platoon_check = false

local enemy = {}

local InfraredVision = false
local NightVision = false

------------------------------------------- Main -----------------------------------------------------
function welcome_message()
	if not sampIsLocalPlayerSpawned() then 
		sampAddChatMessage('[Justice Helper] {ffffff}Инициализация хелпера прошла успешно!',message_color)
		sampAddChatMessage('[Justice Helper] {ffffff}Для полной загрузки хелпера сначало заспавнитесь (войдите на сервер)',message_color)
		repeat wait(0) until sampIsLocalPlayerSpawned()
	end
	sampAddChatMessage('[Justice Helper] {ffffff}Загрузка хелпера прошла успешно!', message_color)
	show_cef_notify('info', 'Justice Helper', "Загрузка хелпера прошла успешно!", 3000)
	if isMonetLoader() or settings.general.bind_mainmenu == nil or not settings.general.use_binds then	
		sampAddChatMessage('[Justice Helper] {ffffff}Чтоб открыть меню хелпера введите команду ' .. message_color_hex .. '/jh', message_color)
	elseif hotkey_no_errors and settings.general.bind_mainmenu and settings.general.use_binds then
		sampAddChatMessage('[Justice Helper] {ffffff}Чтоб открыть меню хелпера нажмите ' .. message_color_hex .. getNameKeysFrom(settings.general.bind_mainmenu) .. ' {ffffff}или введите команду ' .. message_color_hex .. '/jh', message_color)
	else
		sampAddChatMessage('[Justice Helper] {ffffff}Чтоб открыть меню хелпера введите команду ' .. message_color_hex .. '/jh', message_color)
	end
end
function registerCommandsFrom(array)
	for _, command in ipairs(array) do
		if command.enable then
			register_command(command.cmd, command.arg, command.text, tonumber(command.waiting))
		end
	end
end
function register_command(chat_cmd, cmd_arg, cmd_text, cmd_waiting)
	sampRegisterChatCommand(chat_cmd, function(arg)
		if not isActiveCommand then
			local arg_check = false
			local modifiedText = cmd_text
			if cmd_arg == '{arg}' then
				if arg and arg ~= '' then
					modifiedText = modifiedText:gsub('{arg}', arg or "")
					arg_check = true
				else
					sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. chat_cmd .. ' [аргумент]', message_color)
					play_error_sound()
				end
			elseif cmd_arg == '{arg_id}' then
				if isParamSampID(arg) then
					arg = tonumber(arg)
					modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg) or "")
					modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg):gsub('_',' ') or "")
					modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg)) or "")
					modifiedText = modifiedText:gsub('%{arg_id%}', arg or "")
					arg_check = true
				else
					sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. chat_cmd .. ' [ID игрока]', message_color)
					play_error_sound()
				end
			elseif cmd_arg == '{arg_id} {arg2}' then
				if arg and arg ~= '' then
					local arg_id, arg2 = arg:match('(%d+) (.+)')
					if isParamSampID(arg_id) and arg2 then
						arg_id = tonumber(arg_id)
						modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id) or "")
						modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
						modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
						modifiedText = modifiedText:gsub('%{arg_id%}', arg_id or "")
						modifiedText = modifiedText:gsub('%{arg2%}', arg2 or "")
						arg_check = true
					else
						sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. chat_cmd .. ' [ID игрока] [аргумент]', message_color)
						play_error_sound()
					end
				else
					sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. chat_cmd .. ' [ID игрока] [аргумент]', message_color)
					play_error_sound()
				end
            elseif cmd_arg == '{arg_id} {arg2} {arg3}' then
				if arg and arg ~= '' then
					local arg_id, arg2, arg3 = arg:match('(%d+) (%d) (.+)')
					if isParamSampID(arg_id) and arg2 and arg3 then
						arg_id = tonumber(arg_id)
						modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id) or "")
						modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
						modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
						modifiedText = modifiedText:gsub('%{arg_id%}', arg_id or "")
						modifiedText = modifiedText:gsub('%{arg2%}', arg2 or "")
                        modifiedText = modifiedText:gsub('%{arg3%}', arg3 or "")
						arg_check = true
					else
						sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. chat_cmd .. ' [ID игрока] [аргумент] [аргумент]', message_color)
						play_error_sound()
					end
				else
					sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/' .. chat_cmd .. ' [ID игрока] [аргумент] [аргумент]', message_color)
					play_error_sound()
				end
			elseif cmd_arg == '' then
				arg_check = true
			end
			if arg_check then
				lua_thread.create(function()
					isActiveCommand = true
					command_pause = false
					if modifiedText:find('&.+&') then
						if isMonetLoader() and settings.general.mobile_stop_button then
							sampAddChatMessage('[Justice Helper] {ffffff}Чтобы остановить отыгровку команды используйте ' .. message_color_hex .. '/stop {ffffff}или нажмите кнопку внизу экрана', message_color)
							CommandStopWindow[0] = true
						elseif not isMonetLoader() and hotkey_no_errors and settings.general.bind_command_stop and settings.general.use_binds then
							sampAddChatMessage('[Justice Helper] {ffffff}Чтобы остановить отыгровку команды используйте ' .. message_color_hex .. '/stop {ffffff}или нажмите ' .. message_color_hex .. getNameKeysFrom(settings.general.bind_command_stop), message_color)
						else
							sampAddChatMessage('[Justice Helper] {ffffff}Чтобы остановить отыгровку команды используйте ' .. message_color_hex .. '/stop', message_color)
						end
					end
					local lines = {}
					for line in string.gmatch(modifiedText, "[^&]+") do
						table.insert(lines, line)
					end
					for line_index, line in ipairs(lines) do
						if command_stop then 
							command_stop = false 
							isActiveCommand = false
							if isMonetLoader() and settings.general.mobile_stop_button then
								CommandStopWindow[0] = false
							end
							sampAddChatMessage('[Justice Helper] {ffffff}Отыгровка команды /' .. chat_cmd .. " успешно остановлена!", message_color) 
							return 
						end
						for tag, replacement in pairs(tagReplacements) do
							if line:find("{" .. tag .. "}") then
                                local success, result = pcall(string.gsub, line, "{" .. tag .. "}", replacement())
                                if success then
                                    line = result
                                end
                            end
						end
						if line == '{lmenu_vc_vize}' then
							if cmd_arg == '{arg_id}' then
								vc_vize_player_id = arg
							elseif cmd_arg == '{arg_id} {arg2}' then
								local arg_id, arg2 = arg:match('(%d+) (.+)')
								if arg_id and arg2 and isParamSampID(arg_id) then
									vc_vize_player_id = tonumber(arg_id)
								end
							end
							vc_vize_bool = true
							sampSendChat("/lmenu")
							break
						elseif line == '{give_platoon}' then
							if cmd_arg == '{arg_id}' then
								player_id = arg
							elseif cmd_arg == '{arg_id} {arg2}' then
								local arg_id, arg2 = arg:match('(%d+) (.+)')
								if arg_id and arg2 and isParamSampID(arg_id) then
									player_id = arg_id
								end
							end
							platoon_check = true
							sampSendChat("/platoon")
							break
						elseif line == '{show_rank_menu}' then
							if cmd_arg == '{arg_id}' then
								player_id = arg
							elseif cmd_arg == '{arg_id} {arg2}' then
								local arg_id, arg2 = arg:match('(%d+) (.+)')
								if arg_id and arg2 and isParamSampID(arg_id) then
									player_id = arg_id
								end
							end
							GiveRankMenu[0] = true
							break
						elseif line == "{pause}" then
							sampAddChatMessage('[Justice Helper] {ffffff}Команда /' .. chat_cmd .. ' поставлена на паузу!', message_color)
							command_pause = true
							CommandPauseWindow[0] = true
							while command_pause do
								wait(0)
							end
							if not command_stop then
								sampAddChatMessage('[Justice Helper] {ffffff}Продолжаю отыгровку команды /' .. chat_cmd, message_color)	
							end					
						else
							if line_index ~= 1 then wait(cmd_waiting * 1000) end
							sampSendChat(line)
							if debug_mode then sampAddChatMessage('[Justice Helper DEBUG] {ffffff}Отправляю сообщение: ' .. line, message_color) end
						end
					end
					isActiveCommand = false
					if isMonetLoader() and settings.general.mobile_stop_button then
						CommandStopWindow[0] = false
					end
				end)
			end
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Дождитесь завершения отыгровки предыдущей команды!', message_color)
			play_error_sound()
		end
	end)
end
function find_and_use_command(cmd, cmd_arg)
	local check = false
	for _, command in ipairs(commands.commands) do
		if command.enable and command.text:find(cmd) then
			check = true
			sampProcessChatInput("/" .. command.cmd .. " " .. cmd_arg)
			return
		end
	end
	if not check then
		for _, command in ipairs(commands.commands_manage) do
			if command.enable and command.text:find(cmd) then
				check = true
				sampProcessChatInput("/" .. command.cmd .. " " .. cmd_arg)
				return
			end
		end
	end
	if not check then
		sampAddChatMessage('[Justice Helper] {ffffff}Ошибка, не могу найти бинд для выполнения этой команды!', message_color)
		play_error_sound()
		return
	end
end
function initialize_commands()
	sampRegisterChatCommand("jh", function() MainWindow[0] = not MainWindow[0]  end)
	sampRegisterChatCommand("jm", show_fast_menu)
	sampRegisterChatCommand("stop", function() 
		if isActiveCommand then 
			command_stop = true 
		else 
			sampAddChatMessage('[Justice Helper] {ffffff}В данный момент нету никакой активной команды/отыгровки!', message_color) 
			play_error_sound()
		end
	end)
	sampRegisterChatCommand("sum", function(arg) 
		if not isActiveCommand then
			if isParamSampID(arg) then
				if #smart_uk ~= 0 then
					player_id = tonumber(arg)
					SumMenuWindow[0] = true 
				else
					sampAddChatMessage('[Justice Helper] {ffffff}Сначало загрузите/отредактируйте умный розыск в /jh', message_color)
					play_error_sound()
				end
			else
				sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/sum [ID игрока]', message_color)
				play_error_sound()
			end	
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Дождитесь завершения отыгровки предыдущей команды!', message_color)
			play_error_sound()
		end

	end)
	sampRegisterChatCommand("tsm", function(arg) 
		if not isActiveCommand then
			if isParamSampID(arg) then
				if #smart_pdd ~= 0 then
					player_id = tonumber(arg)
					TsmMenuWindow[0] = true 
				else
					sampAddChatMessage('[Justice Helper] {ffffff}Сначало загрузите/отредактируйте умные штрафы в /jh', message_color)
					play_error_sound()
				end
			else
				sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/tsm [ID игрока]', message_color)
				play_error_sound()
			end	
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Дождитесь завершения отыгровки предыдущей команды!', message_color)
			play_error_sound()
		end
	end)
	sampRegisterChatCommand("sob", function(arg)
		if not isActiveCommand then
			if isParamSampID(arg) then
				player_id = tonumber(arg)
				SobesMenu[0] = not SobesMenu[0]
			else
				sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/sob [ID игрока]', message_color)
				play_error_sound()
			end	
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Дождитесь завершения отыгровки предыдущей команды!', message_color)
			play_error_sound()
		end
	end)
		sampRegisterChatCommand("dop", function(arg)
		if not isActiveCommand then
			if isParamSampID(arg) then
				player_id = tonumber(arg)
				DoprosMenu[0] = not DoprosMenu[0]
			else
				sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/dop [ID игрока]', message_color)
				play_error_sound()
			end	
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Дождитесь завершения отыгровки предыдущей команды!', message_color)
			play_error_sound()
		end
	end)
	sampRegisterChatCommand("pnv", function(arg)
		if not isActiveCommand then
			NightVision = not NightVision
			if NightVision then
				sampSendChat('/me достаёт из кармана очки ночного видения и надевает их')
			else
				sampSendChat('/me снимает с себя очки ночного видения и убирает их в карман')
			end
			setNightVision(NightVision)	
			InfraredVision = false
			setInfraredVision(InfraredVision)	
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Дождитесь завершения отыгровки предыдущей команды!', message_color)
			play_error_sound()
		end
	end)
	sampRegisterChatCommand("irv", function(arg)
		if not isActiveCommand then
			InfraredVision = not InfraredVision
			setInfraredVision(InfraredVision)	
			NightVision = false
			setNightVision(NightVision)	
			if InfraredVision then
				sampSendChat('/me достаёт из кармана инфакрасные очки и надевает их')
			else
				sampSendChat('/me снимает с себя инфакрасные очки и убирает их в карман')
			end
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Дождитесь завершения отыгровки предыдущей команды!', message_color)
			play_error_sound()
		end
	end)
	sampRegisterChatCommand("wanteds", function(arg)
		if WantedWindow[0] then
			WantedWindow[0] = false
			sampAddChatMessage('[Justice Helper] {ffffff}Меню списка преступников закрыто!', message_color)
		elseif not isActiveCommand then
			lua_thread.create(function()
				sampAddChatMessage('[Justice Helper] {ffffff}Начинаю сканирование /wanted [1-7], ожидайте...', message_color)
				show_cef_notify('info', 'Justice Helper', "Сканирование /wanted...", 2500)
				wanted_new = {}
				check_wanted = true
				for i = 7, 1, -1 do
					sampSendChat('/wanted ' .. i)
					wait(300)
				end
				check_wanted = false
				if #wanted_new == 0 then
					sampAddChatMessage('[Justice Helper] {ffffff}Сейчас на сервере нету игроков с розыском!', message_color)
				else
					sampAddChatMessage('[Justice Helper] {ffffff}Сканирование успешно заверешено, данные в меню будут обновляються каждые 3 секунды.', message_color)
					sampAddChatMessage('[Justice Helper] {ffffff}ВНИМАНИЕ! Из-за постоянного обновления данных плохо работают диалоги и чат!', message_color)
					sampAddChatMessage('[Justice Helper] {ffffff}Чтобы диалоги и чат работали стабильно, закройте меню списка преступников!', message_color)
					wanted = wanted_new
					WantedWindow[0] = true
				end
			end)
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Дождитесь завершения отыгровки предыдущей команды!', message_color)
			play_error_sound()
		end
	end)
	sampRegisterChatCommand("debug", function() debug_mode = not debug_mode end)
	sampRegisterChatCommand("mask", function() 
		if not isActiveCommand then
			isActiveCommand = true
			if isMonetLoader() and settings.general.mobile_stop_button then
				sampAddChatMessage('[Justice Helper] {ffffff}Чтобы остановить отыгровку команды используйте ' .. message_color_hex .. '/stop {ffffff}или нажмите кнопку внизу экрана', message_color)
				CommandStopWindow[0] = true
			elseif not isMonetLoader() and hotkey_no_errors and settings.general.bind_command_stop and settings.general.use_binds then
				sampAddChatMessage('[Justice Helper] {ffffff}Чтобы остановить отыгровку команды используйте ' .. message_color_hex .. '/stop {ffffff}или нажмите ' .. message_color_hex .. getNameKeysFrom(settings.general.bind_command_stop), message_color)
			else
				sampAddChatMessage('[Justice Helper] {ffffff}Чтобы остановить отыгровку команды используйте ' .. message_color_hex .. '/stop', message_color)
			end
			if sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) == 23486046 then
				lua_thread.create(function()
					sampSendChat('/do Балаклава на голове.')
					wait(1200)
					if command_stop then 
						command_stop = false 
						isActiveCommand = false
						if isMonetLoader() and settings.general.mobile_stop_button then
							CommandStopWindow[0] = false
						end
						sampAddChatMessage('[Justice Helper] {ffffff}Отыгровка команды /mask успешно остановлена!', message_color) 
						return
					end
					sampSendChat('/me стягивает балаклаву с головы и прицепляет её к тактичекому поясу')
					wait(1200)
					if command_stop then 
						command_stop = false 
						isActiveCommand = false
						if isMonetLoader() and settings.general.mobile_stop_button then
							CommandStopWindow[0] = false
						end
						sampAddChatMessage('[Justice Helper] {ffffff}Отыгровка команды /mask успешно остановлена!', message_color) 
						return
					end
					sampSendChat('/mask')
					wait(1200)
					if command_stop then 
						command_stop = false 
						isActiveCommand = false
						if isMonetLoader() and settings.general.mobile_stop_button then
							CommandStopWindow[0] = false
						end
						sampAddChatMessage('[Justice Helper] {ffffff}Отыгровка команды /mask успешно остановлена!', message_color) 
						return
					end
					sampSendChat('/do Балаклава прикреплена к тактическому поясу.')
					isActiveCommand = false
				end)
			else
				lua_thread.create(function()
					sampSendChat('/do Балаклава прикреплена к тактическому поясу.')
					wait(1200)
					if command_stop then 
						command_stop = false 
						isActiveCommand = false
						if isMonetLoader() and settings.general.mobile_stop_button then
							CommandStopWindow[0] = false
						end
						sampAddChatMessage('[Justice Helper] {ffffff}Отыгровка команды /mask успешно остановлена!', message_color)  
						return
					end
					sampSendChat('/me достаёт балаклаву и натягивает её себе на голову')
					wait(1200)
					if command_stop then 
						command_stop = false 
						isActiveCommand = false
						if isMonetLoader() and settings.general.mobile_stop_button then
							CommandStopWindow[0] = false
						end
						sampAddChatMessage('[Justice Helper] {ffffff}Отыгровка команды /mask успешно остановлена!', message_color) 
						return
					end
					sampSendChat('/mask')
					wait(1200)
					if command_stop then 
						command_stop = false 
						isActiveCommand = false
						if isMonetLoader() and settings.general.mobile_stop_button then
							CommandStopWindow[0] = false
						end
						sampAddChatMessage('[Justice Helper] {ffffff}Отыгровка команды /mask успешно остановлена!', message_color) 
						return
					end
					sampSendChat('/do Балаклава на голове.')
					isActiveCommand = false
				end)
			end
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Дождитесь завершения отыгровки предыдущей команды!', message_color)
			play_error_sound()
		end
	end)
	sampRegisterChatCommand("patrool", function(arg)
		if not isActiveCommand then
			PatroolMenu[0] = not PatroolMenu[0]
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Дождитесь завершения отыгровки предыдущей команды!', message_color)
			play_error_sound()
		end
	end)
	sampRegisterChatCommand("mb", function(arg)
		if not isActiveCommand then
			if MembersWindow[0] then
				MembersWindow[0] = false
			else
				members_new = {} 
				members_check = true 
				sampSendChat("/members")
				--MembersWindow[0] = true
			end
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Дождитесь завершения отыгровки предыдущей команды!', message_color)
			play_error_sound()
		end
	end)
	sampRegisterChatCommand("dep", function(arg)
		if not isActiveCommand then
			DeportamentWindow[0] = not DeportamentWindow[0]
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Дождитесь завершения отыгровки предыдущей команды!', message_color)
			play_error_sound()
		end
	end)
	-- Ригистрация всех команд которые есть в json
	registerCommandsFrom(commands.commands)
	if tonumber(settings.player_info.fraction_rank_number) >= 9 then 
		sampRegisterChatCommand("jlm", show_leader_fast_menu)
		sampRegisterChatCommand("spcar", function()
			if not isActiveCommand then
				lua_thread.create(function()
					isActiveCommand = true
					if isMonetLoader() and settings.general.mobile_stop_button then
						sampAddChatMessage('[Justice Helper] {ffffff}Чтобы остановить отыгровку команды используйте ' .. message_color_hex .. '/stop {ffffff}или нажмите кнопку внизу экрана', message_color)
						CommandStopWindow[0] = true
					elseif not isMonetLoader() and hotkey_no_errors and settings.general.bind_command_stop and settings.general.use_binds then
						sampAddChatMessage('[Justice Helper] {ffffff}Чтобы остановить отыгровку команды используйте ' .. message_color_hex .. '/stop {ffffff}или нажмите ' .. message_color_hex .. getNameKeysFrom(settings.general.bind_command_stop), message_color)
					else
						sampAddChatMessage('[Justice Helper] {ffffff}Чтобы остановить отыгровку команды используйте ' .. message_color_hex .. '/stop', message_color)
					end
					sampSendChat("/rb Внимание! Через 15 секунд будет спавн транспорта организации.")
					wait(1500)
					if command_stop then 
						command_stop = false 
						isActiveCommand = false
						if isMonetLoader() and settings.general.mobile_stop_button then
							CommandStopWindow[0] = false
						end
						sampAddChatMessage('[Justice Helper] {ffffff}Отыгровка команды /spcar успешно остановлена!', message_color) 
						return
					end
					sampSendChat("/rb Займите транспорт, иначе он будет заспавнен.")
					wait(13500)	
					if command_stop then 
						command_stop = false 
						isActiveCommand = false
						if isMonetLoader() and settings.general.mobile_stop_button then
							CommandStopWindow[0] = false
						end
						sampAddChatMessage('[Justice Helper] {ffffff}Отыгровка команды /spcar успешно остановлена!', message_color) 
						return
					end
					spawncar_bool = true
					sampSendChat("/lmenu")
					isActiveCommand = false
					if isMonetLoader() and settings.general.mobile_stop_button then
						CommandStopWindow[0] = false
					end
				end)
			else
				sampAddChatMessage('[Justice Helper] {ffffff}Дождитесь завершения отыгровки предыдущей команды!', message_color)
			end
		end)
		-- Ригистрация всех команд которые есть в json для 9/10
		registerCommandsFrom(commands.commands_manage) 
	end
end
local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- Ё
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then -- lower russian characters
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then -- ё
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function TranslateNick(name)
	if name:match('%a+') then
        for k, v in pairs({['ph'] = 'ф',['Ph'] = 'Ф',['Ch'] = 'Ч',['ch'] = 'ч',['Th'] = 'Т',['th'] = 'т',['Sh'] = 'Ш',['sh'] = 'ш', ['ea'] = 'и',['Ae'] = 'Э',['ae'] = 'э',['size'] = 'сайз',['Jj'] = 'Джейджей',['Whi'] = 'Вай',['lack'] = 'лэк',['whi'] = 'вай',['Ck'] = 'К',['ck'] = 'к',['Kh'] = 'Х',['kh'] = 'х',['hn'] = 'н',['Hen'] = 'Ген',['Zh'] = 'Ж',['zh'] = 'ж',['Yu'] = 'Ю',['yu'] = 'ю',['Yo'] = 'Ё',['yo'] = 'ё',['Cz'] = 'Ц',['cz'] = 'ц', ['ia'] = 'я', ['ea'] = 'и',['Ya'] = 'Я', ['ya'] = 'я', ['ove'] = 'ав',['ay'] = 'эй', ['rise'] = 'райз',['oo'] = 'у', ['Oo'] = 'У', ['Ee'] = 'И', ['ee'] = 'и', ['Un'] = 'Ан', ['un'] = 'ан', ['Ci'] = 'Ци', ['ci'] = 'ци', ['yse'] = 'уз', ['cate'] = 'кейт', ['eow'] = 'яу', ['rown'] = 'раун', ['yev'] = 'уев', ['Babe'] = 'Бэйби', ['Jason'] = 'Джейсон', ['liy'] = 'лий', ['ane'] = 'ейн', ['ame'] = 'ейм'}) do
            name = name:gsub(k, v) 
        end
		for k, v in pairs({['B'] = 'Б',['Z'] = 'З',['T'] = 'Т',['Y'] = 'Й',['P'] = 'П',['J'] = 'Дж',['X'] = 'Кс',['G'] = 'Г',['V'] = 'В',['H'] = 'Х',['N'] = 'Н',['E'] = 'Е',['I'] = 'И',['D'] = 'Д',['O'] = 'О',['K'] = 'К',['F'] = 'Ф',['y`'] = 'ы',['e`'] = 'э',['A'] = 'А',['C'] = 'К',['L'] = 'Л',['M'] = 'М',['W'] = 'В',['Q'] = 'К',['U'] = 'А',['R'] = 'Р',['S'] = 'С',['zm'] = 'зьм',['h'] = 'х',['q'] = 'к',['y'] = 'и',['a'] = 'а',['w'] = 'в',['b'] = 'б',['v'] = 'в',['g'] = 'г',['d'] = 'д',['e'] = 'е',['z'] = 'з',['i'] = 'и',['j'] = 'ж',['k'] = 'к',['l'] = 'л',['m'] = 'м',['n'] = 'н',['o'] = 'о',['p'] = 'п',['r'] = 'р',['s'] = 'с',['t'] = 'т',['u'] = 'у',['f'] = 'ф',['x'] = 'x',['c'] = 'к',['``'] = 'ъ',['`'] = 'ь',['_'] = ' '}) do
            name = name:gsub(k, v) 
        end
        return name
    end
	return name
end
function isParamSampID(id)
	id = tonumber(id)
	if id ~= nil and tostring(id):find('%d') and not tostring(id):find('%D') and string.len(id) >= 1 and string.len(id) <= 3 then
		if id == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
			return true
		elseif sampIsPlayerConnected(id) then
			return true
		else
			return false
		end
	else
		return false
	end
end
function play_error_sound()
	if not isMonetLoader() and sampIsLocalPlayerSpawned() then
		addOneOffSound(getCharCoordinates(PLAYER_PED), 1149)
	end
	show_cef_notify('error', 'Justice Helper', "Произошла ошибка!", 1500)
end
function show_fast_menu(id)
	if isParamSampID(id) then 
		player_id = tonumber(id)
		FastMenu[0] = true
	else
		if isMonetLoader() or settings.general.bind_fastmenu == nil then
			if not FastMenuPlayers[0] then
				sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/jm [ID]', message_color)
			end
		elseif settings.general.bind_fastmenu and settings.general.use_binds and hotkey_no_errors then
			sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/jm [ID] {ffffff}или наведитесь на игрока через ' .. message_color_hex .. 'ПКМ + ' .. getNameKeysFrom(settings.general.bind_fastmenu), message_color) 
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/jm [ID]', message_color)
		end 
		play_error_sound()
	end 
end
function show_leader_fast_menu(id)
	if isParamSampID(id) then
		player_id = tonumber(id)
		LeaderFastMenu[0] = true
	else
		if isMonetLoader() or settings.general.bind_leader_fastmenu == nil then
			sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/jlm [ID]', message_color)
		elseif settings.general.bind_leader_fastmenu and settings.general.use_binds and hotkey_no_errors then
			sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/jlm [ID] {ffffff}или наведитесь на игрока через ' .. message_color_hex .. 'ПКМ + ' .. getNameKeysFrom(settings.general.bind_leader_fastmenu), message_color) 
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. '/jlm [ID]', message_color)
		end 
		play_error_sound()
	end
end
function get_players()
	local myPlayerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
	local playersInRange = {}
	for temp1, h in pairs(getAllChars()) do
		temp2, id = sampGetPlayerIdByCharHandle(h)
		temp3, m = sampGetPlayerIdByCharHandle(PLAYER_PED)
		id = tonumber(id)
		if id ~= -1 and id ~= m and doesCharExist(h) then
			local x, y, z = getCharCoordinates(h)
			local mx, my, mz = getCharCoordinates(PLAYER_PED)
			local dist = getDistanceBetweenCoords3d(mx, my, mz, x, y, z)
			if dist <= 5 then
				table.insert(playersInRange, id)
			end
		end
	end
	return playersInRange
end
function show_cef_notify(type, title, text, time)
	--[[
	1) type - тип уведомления ( 'info' / 'error' / 'success' / 'halloween' / '' )
	2) title - текст заголовка/названия уведомления ( указывайте текст )
	3) text - текст содержимого уведомления ( указывайте текст )
	4) time - время отображения уведомления в миллисекундах ( указывайте любое число ).
	]]
    local str = ('window.executeEvent(\'event.notify.initialize\', \'["%s", "%s", "%s", "%s"]\');'):format(type, title, text, time)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 17)
    raknetBitStreamWriteInt32(bs, 0)
    raknetBitStreamWriteInt32(bs, #str)
    raknetBitStreamWriteString(bs, str)
    raknetEmulPacketReceiveBitStream(220, bs)
    raknetDeleteBitStream(bs)
end
function code(code)
    local bs = raknetNewBitStream();
    raknetBitStreamWriteInt8(bs, 17);
    raknetBitStreamWriteInt32(bs, 0);
    raknetBitStreamWriteInt32(bs, string.len(code));
    raknetBitStreamWriteString(bs, code);
    raknetEmulPacketReceiveBitStream(220, bs);
    raknetDeleteBitStream(bs);
end
function openLink(link)
	if isMonetLoader() then
		gta._Z12AND_OpenLinkPKc(link)
	else
		os.execute("explorer " .. link)
	end
end
function sampGetPlayerIdByNickname(nick)
	local id = nil
	nick = tostring(nick)
	local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if nick == sampGetPlayerNickname(myid) then return myid end
	for i = 0, 999 do
	    if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
		   id = i
		   break
	    end
	end
	return id
end
local weapons = {
	FIST = 0,
	BRASSKNUCKLES = 1,
	GOLFCLUB = 2,
	NIGHTSTICK = 3,
	KNIFE = 4,
	BASEBALLBAT = 5,
	SHOVEL = 6,
	POOLCUE = 7,
	KATANA = 8,
	CHAINSAW = 9,
	PURPLEDILDO = 10,
	WHITEDILDO = 11,
	WHITEVIBRATOR = 12,
	SILVERVIBRATOR = 13,
	FLOWERS = 14,
	CANE = 15,
	GRENADE = 16,
	TEARGAS = 17,
	MOLOTOV = 18,
	COLT45 = 22,
	SILENCED = 23,
	DESERTEAGLE = 24,
	SHOTGUN = 25,
	SAWNOFFSHOTGUN = 26,
	COMBATSHOTGUN = 27,
	UZI = 28,
	MP5 = 29,
	AK47 = 30,
	M4 = 31,
	TEC9 = 32,
	RIFLE = 33,
	SNIPERRIFLE = 34,
	ROCKETLAUNCHER = 35,
	HEATSEEKER = 36,
	FLAMETHROWER = 37,
	MINIGUN = 38,
	SATCHELCHARGE = 39,
	DETONATOR = 40,
	SPRAYCAN = 41,
	FIREEXTINGUISHER = 42,
	CAMERA = 43,
	NIGHTVISION = 44,
	THERMALVISION = 45,
	PARACHUTE = 46,
	WEAPON_VEHICLE = 49,
	HELI = 50,
	BOMB = 51,
	COLLISION = 54,
	-- ARZ CUSTOM GUN
	DEAGLE_STEEL = 71,
	DEAGLE_GOLD = 72,
	GLOCK_GRADIENT = 73,
	DEAGLE_FLAME = 74,
	PYTHON_ROYAL = 75,
	PYTHON_SILVER = 76,
	AK47_ROSES = 77,
	AK47_GOLD = 78,
	M249_GRAFFITI = 79,
	SAIGA_GOLD = 80,
	PPSH_STANDART = 81,
	M249_STANDART = 82,
	SKORP_STANDART = 83,
	AKS74_CAMOUFLAGE1 = 84,
	AK47_CAMOUFLAGE1 = 85,
	REBECCA_SHOTGUN = 86,
	OBJ58_PORTALGUN = 87,
	ICE_SWORD = 88,
	PORTALGUN = 89,
	SOUND_GRENADE = 90,
	EYE_GRENADE = 91,
	MCMILLIAN_TAC50 = 92
}
local id = weapons
weapons.names = {
	[id.FIST] = 'кулаки',
	[id.BRASSKNUCKLES] = 'кастеты',
	[id.GOLFCLUB] = 'клюшку для гольфа',
	[id.NIGHTSTICK] = 'дубинку',
	[id.KNIFE] = 'острый нож',
	[id.BASEBALLBAT] = 'биту',
	[id.SHOVEL] = 'лопату',
	[id.POOLCUE] = 'кий',
	[id.KATANA] = 'катану',
	[id.CHAINSAW] = 'бензопилу',
	[id.PURPLEDILDO] = 'дидло',
	[id.WHITEDILDO] = 'дидло',
	[id.WHITEVIBRATOR] = 'вибратор',
	[id.SILVERVIBRATOR] = 'вибратор',
	[id.FLOWERS] = 'букет цветов',
	[id.CANE] = 'трость',
	[id.GRENADE] = 'осколочную гранату',
	[id.TEARGAS] = 'дымовую гранату',
	[id.MOLOTOV] = 'коктейль Молотова',
	[id.COLT45] = 'пистолет Colt45',
	[id.SILENCED] = "электрошокер Taser-X26P",
	[id.DESERTEAGLE] = 'пистолет Desert Eagle',
	[id.SHOTGUN] = 'дробовик',
	[id.SAWNOFFSHOTGUN] = 'обрез',
	[id.COMBATSHOTGUN] = 'улучшенный обрез',
	[id.UZI] = 'пистолет-пулемёт Micro Uzi',
	[id.MP5] = 'пистолет-пулемёт MP5',
	[id.AK47] = 'автомат AK-47',
	[id.M4] = 'автомат M4',
	[id.TEC9] = 'пистолет-пулемёт Tec-9',
	[id.RIFLE] = 'винтовку Rifle',
	[id.SNIPERRIFLE] = 'снайперскую винтовку Rifle',
	[id.ROCKETLAUNCHER] = 'ручную противотанковую ракету',
	[id.HEATSEEKER] = 'устройство для запуска ракет',
	[id.FLAMETHROWER] = 'огнемёт',
	[id.MINIGUN] = 'миниган',
	[id.SATCHELCHARGE] = 'динамит',
	[id.DETONATOR] = 'детонатор',
	[id.SPRAYCAN] = 'перцовый баланчик',
	[id.FIREEXTINGUISHER] = 'огнетушитель',
	[id.CAMERA] = 'фотоапарат Canon',
	[id.NIGHTVISION] = 'прибор ночного видения',
	[id.THERMALVISION] = 'тепловизор',
	[id.PARACHUTE] = 'ручной парашут',
	[id.WEAPON_VEHICLE] = 'автомобиль',
	[id.HELI] = 'лопасти вертолёта',
	[id.BOMB] = 'взрыв',
	[id.COLLISION] = 'коллизию',
	-- ARZ LAUNCHER GUNS
	[id.DEAGLE_STEEL] = 'пистолет Desert Eagle Steel',
	[id.DEAGLE_GOLD] = 'пистолет Desert Eagle Gold',
	[id.GLOCK_GRADIENT] = 'пистолет Glock',
	[id.DEAGLE_FLAME] = 'пистолет Desert Eagle Flame',
	[id.PYTHON_ROYAL] = 'пистолет Colt Python',
	[id.PYTHON_SILVER] = 'пистолет Colt Python Silver',
	[id.AK47_ROSES] = 'автомат AK-47 Roses',
	[id.AK47_GOLD] = 'автомат AK-47 Gold',
	[id.M249_GRAFFITI] = 'пулемёт M249 Graffiti',	
	[id.SAIGA_GOLD] = 'золотую Сайгу',
	[id.PPSH_STANDART] = 'пистолет-пулемёт Standart',
	[id.M249_STANDART] = 'пулемёт M249',
	[id.SKORP_STANDART] = 'пистолет-пулемёт Skorp',
	[id.AKS74_CAMOUFLAGE1] = 'автомат AKS-74 камуфляжный',
	[id.AK47_CAMOUFLAGE1] = 'автомат AK-47 камуфляжный',
	[id.REBECCA_SHOTGUN] = 'дробовик Rebecca',
	[id.OBJ58_PORTALGUN] = 'портальную пушку',
	[id.PORTALGUN] = 'портальную пушку',
	[id.ICE_SWORD] = 'ледяной меч',
	[id.SOUND_GRENADE] = 'оглушающую граната',
	[id.EYE_GRENADE] = 'ослепляющую граната',
	[id.MCMILLIAN_TAC50] = 'снайперскую винтовку McMillian TAC-50'
}
function weapons.get_name(id) 
	return weapons.names[id]
end
local gunOn = {}
local gunOff = {}
local gunPartOn = {}
local gunPartOff = {}
local oldGun = nil
local nowGun = 0
local rpTakeNames = {{"из-за спины", "за спину"}, {"из кармана", "в карман"}, {"из пояса", "на пояс"}, {"из кобуры", "в кобуру"}}
local rpTake = {
	[2]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [14]=1, [15]=1, [25]=1, [26]=1, [27]=1, [28]=1, [29]=1, [30]=1, [31]=1, [32]=1, [33]=1, [34]=1, [35]=1, [36]=1, [37]=1, [38]=1, [42]=1, [77]=1, [78]=1, [78]=1, [79]=1, [80]=1, [81]=1, [82]=1, [83]=1, [84]=1, [85]=1, [86]=1, [92]=1, [87]=1, [88]=1, [49]=1, [50]=1, [51]=1, [54]=1, -- спина
	[1]=2, [4]=2, [10]=2, [11]=2, [12]=2, [13]=2, [41]=2, [43]=2, [44]=2, [45]=2, [46]=2, -- карман
	[16]=3, [17]=3, [18]=3, [39]=3, [40]=3, [90]=3, [91]=3, [3]=3,  -- пояс
	[22]=4, [23]=4, [24]=4, [71]=4, [72]=4, [73]=4, [74]=4, [75]=4, [76]=4, [89]=4, -- кобура
}
for id, weapon in pairs(weapons.names) do
	if (id == 3 or (id > 15 and id < 19) or (id == 90 or id == 91)) then -- 3 16 17 18 (for gunOn)
		if settings.player_info.sex == "Мужчина" or settings.player_info.sex  then
			gunOn[id] = 'снял'
		elseif settings.player_info.sex == "Женщина" then
			gunOn[id] = 'снялa'
		end
	else
		if settings.player_info.sex == "Мужчина" or settings.player_info.sex == "Неизвестно" then
			gunOn[id] = 'достал'
		elseif settings.player_info.sex == "Женщина" then
			gunOn[id] = 'досталa'
		end
	end
	if (id == 3 or (id > 15 and id < 19) or (id > 38 and id < 41) or (id == 90 or id == 91)) then -- 3 16 17 18 39 40 (for gunOff)
		if settings.player_info.sex == "Мужчина" or settings.player_info.sex == "Неизвестно" then
			gunOff[id] = 'повесил'
		elseif settings.player_info.sex == "Женщина" then
			gunOff[id] = 'повесилa'
		end
	else
		if settings.player_info.sex == "Мужчина" or settings.player_info.sex == "Неизвестно" then
			gunOff[id] = 'убрал'
		elseif settings.player_info.sex == "Женщина" then
			gunOff[id] = 'убралa'
		end
	end
	if id > 0 then
		gunPartOn[id] = rpTakeNames[rpTake[id]][1]
		gunPartOff[id] = rpTakeNames[rpTake[id]][2]
	end
end
function format_patrool_time(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    if hours > 0 then
        return string.format("%d часов %d минут %d секунд", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%d минут %d секунд", minutes, secs)
    else
        return string.format("%d секунд(-ы)", secs)
    end
end
function getNameOfARZVehicleModel(id)
	if doesFileExist(path_arzvehicles) then
		if #arzvehicles ~= 0 then
			for _, vehicle in ipairs(arzvehicles) do
				if vehicle.model_id == id then
					--sampAddChatMessage("[Justice Helper] {ffffff}Самый ближайший транспорта к вам это " .. vehicle.name ..  " [ID " .. id .. "].", message_color)
					return vehicle.name
				end
			end
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Не удалось получить модель транспорта с ID ' .. id .. "! Причина: ошибка инициализации VehiclesArizona.json", message_color)
			load_arzvehicles()
			return ''
		end
	else
		sampAddChatMessage('[Justice Helper] {ffffff}Не удалось получить модель транспорта с ID ' .. id .. "! Причина: отсуствует файл VehiclesArizona.json", message_color)
		sampAddChatMessage('[Justice Helper] {ffffff}Пытаюсь скачать файл VehiclesArizona.json в папку ' .. path_arzvehicles, message_color)
		download_arzvehicles = true
		downloadFileFromUrlToPath('https://raw.githubusercontent.com/MTGMODS/justice-helper/main/VehiclesArizona/VehiclesArizona.json', path_arzvehicles)
		return ''
	end
end
function kvadrat()
    local KV = {
        [1] = "А",
        [2] = "Б",
        [3] = "В",
        [4] = "Г",
        [5] = "Д",
        [6] = "Ж",
        [7] = "З",
        [8] = "И",
        [9] = "К",
        [10] = "Л",
        [11] = "М",
        [12] = "Н",
        [13] = "О",
        [14] = "П",
        [15] = "Р",
        [16] = "С",
        [17] = "Т",
        [18] = "У",
        [19] = "Ф",
        [20] = "Х",
        [21] = "Ц",
        [22] = "Ч",
        [23] = "Ш",
        [24] = "Я",
    }
    local X, Y, Z = getCharCoordinates(playerPed)
    X = math.ceil((X + 3000) / 250)
    Y = math.ceil((Y * - 1 + 3000) / 250)
    Y = KV[Y]
	if Y ~= nil then
		local KVX = (Y.."-"..X)
		return KVX
	else
		return X
	end
   
end
function calculateZoneRu(x, y, z)
    local streets = {
        {"Клуб Ависпа", -2667.810, -302.135, -28.831, -2646.400, -262.320, 71.169},
        {"Аэропорт", -1315.420, -405.388, 15.406, -1264.400, -209.543, 25.406},
        {"Клуб Ависпа", -2550.040, -355.493, 0.000, -2470.040, -318.493, 39.700},
        {"Аэропорт", -1490.330, -209.543, 15.406, -1264.400, -148.388, 25.406},
        {"Гарсия", -2395.140, -222.589, -5.3, -2354.090, -204.792, 200.000},
        {"Шейди-Кэбин", -1632.830, -2263.440, -3.0, -1601.330, -2231.790, 200.000},
        {"Восточный ЛС", 2381.680, -1494.030, -89.084, 2421.030, -1454.350, 110.916},
        {"Грузовое депо", 1236.630, 1163.410, -89.084, 1277.050, 1203.280, 110.916},
        {"Пересечение Блэкфилд", 1277.050, 1044.690, -89.084, 1315.350, 1087.630, 110.916},
        {"Клуб Ависпа", -2470.040, -355.493, 0.000, -2270.040, -318.493, 46.100},
        {"Темпл", 1252.330, -926.999, -89.084, 1357.000, -910.170, 110.916},
        {"Станция Юнити", 1692.620, -1971.800, -20.492, 1812.620, -1932.800, 79.508},
        {"Грузовое депо ЛВ", 1315.350, 1044.690, -89.084, 1375.600, 1087.630, 110.916},
        {"Лос-Флорес", 2581.730, -1454.350, -89.084, 2632.830, -1393.420, 110.916},
        {"Казино", 2437.390, 1858.100, -39.084, 2495.090, 1970.850, 60.916},
        {"Химзавод Истер-Бэй", -1132.820, -787.391, 0.000, -956.476, -768.027, 200.000},
        {"Деловой район", 1370.850, -1170.870, -89.084, 1463.900, -1130.850, 110.916},
        {"Восточная Эспаланда", -1620.300, 1176.520, -4.5, -1580.010, 1274.260, 200.000},
        {"Станция Маркет", 787.461, -1410.930, -34.126, 866.009, -1310.210, 65.874},
        {"Станция Линден", 2811.250, 1229.590, -39.594, 2861.250, 1407.590, 60.406},
        {"Пересечение Монтгомери", 1582.440, 347.457, 0.000, 1664.620, 401.750, 200.000},
        {"Мост Фредерик", 2759.250, 296.501, 0.000, 2774.250, 594.757, 200.000},
        {"Станция Йеллоу-Белл", 1377.480, 2600.430, -21.926, 1492.450, 2687.360, 78.074},
        {"Деловой район", 1507.510, -1385.210, 110.916, 1582.550, -1325.310, 335.916},
        {"Джефферсон", 2185.330, -1210.740, -89.084, 2281.450, -1154.590, 110.916},
        {"Малхолланд", 1318.130, -910.170, -89.084, 1357.000, -768.027, 110.916},
        {"Клуб Ависпа", -2361.510, -417.199, 0.000, -2270.040, -355.493, 200.000},
        {"Джефферсон", 1996.910, -1449.670, -89.084, 2056.860, -1350.720, 110.916},
        {"Западаное шоссе", 1236.630, 2142.860, -89.084, 1297.470, 2243.230, 110.916},
        {"Джефферсон", 2124.660, -1494.030, -89.084, 2266.210, -1449.670, 110.916},
        {"Северное шоссе", 1848.400, 2478.490, -89.084, 1938.800, 2553.490, 110.916},
        {"Родео", 422.680, -1570.200, -89.084, 466.223, -1406.050, 110.916},
        {"Станция Крэнберри", -2007.830, 56.306, 0.000, -1922.000, 224.782, 100.000},
        {"Деловой район", 1391.050, -1026.330, -89.084, 1463.900, -926.999, 110.916},
        {"Западный Рэдсэндс", 1704.590, 2243.230, -89.084, 1777.390, 2342.830, 110.916},
        {"Маленькая Мексика", 1758.900, -1722.260, -89.084, 1812.620, -1577.590, 110.916},
        {"Пересечение Блэкфилд", 1375.600, 823.228, -89.084, 1457.390, 919.447, 110.916},
        {"Аэропорт", 1974.630, -2394.330, -39.084, 2089.000, -2256.590, 60.916},
        {"Бекон-Хилл", -399.633, -1075.520, -1.489, -319.033, -977.516, 198.511},
        {"Родео", 334.503, -1501.950, -89.084, 422.680, -1406.050, 110.916},
        {"Ричман", 225.165, -1369.620, -89.084, 334.503, -1292.070, 110.916},
        {"Деловой район", 1724.760, -1250.900, -89.084, 1812.620, -1150.870, 110.916},
        {"Стрип-клуб", 2027.400, 1703.230, -89.084, 2137.400, 1783.230, 110.916},
        {"Деловой район", 1378.330, -1130.850, -89.084, 1463.900, -1026.330, 110.916},
        {"Пересечение Блэкфилд", 1197.390, 1044.690, -89.084, 1277.050, 1163.390, 110.916},
        {"Конференц Центр", 1073.220, -1842.270, -89.084, 1323.900, -1804.210, 110.916},
        {"Монтгомери", 1451.400, 347.457, -6.1, 1582.440, 420.802, 200.000},
        {"Долина Фостер", -2270.040, -430.276, -1.2, -2178.690, -324.114, 200.000},
        {"Часовня Блэкфилд", 1325.600, 596.349, -89.084, 1375.600, 795.010, 110.916},
        {"Аэропорт", 2051.630, -2597.260, -39.084, 2152.450, -2394.330, 60.916},
        {"Малхолланд", 1096.470, -910.170, -89.084, 1169.130, -768.027, 110.916},
        {"Поле для гольфа", 1457.460, 2723.230, -89.084, 1534.560, 2863.230, 110.916},
        {"Стрип", 2027.400, 1783.230, -89.084, 2162.390, 1863.230, 110.916},
        {"Джефферсон", 2056.860, -1210.740, -89.084, 2185.330, -1126.320, 110.916},
        {"Малхолланд", 952.604, -937.184, -89.084, 1096.470, -860.619, 110.916},
        {"Альдеа-Мальвада", -1372.140, 2498.520, 0.000, -1277.590, 2615.350, 200.000},
        {"Лас-Колинас", 2126.860, -1126.320, -89.084, 2185.330, -934.489, 110.916},
        {"Лас-Колинас", 1994.330, -1100.820, -89.084, 2056.860, -920.815, 110.916},
        {"Ричман", 647.557, -954.662, -89.084, 768.694, -860.619, 110.916},
        {"Грузовое депо", 1277.050, 1087.630, -89.084, 1375.600, 1203.280, 110.916},
        {"Северное шоссе", 1377.390, 2433.230, -89.084, 1534.560, 2507.230, 110.916},
        {"Уиллоуфилд", 2201.820, -2095.000, -89.084, 2324.000, -1989.900, 110.916},
        {"Северное шоссе", 1704.590, 2342.830, -89.084, 1848.400, 2433.230, 110.916},
        {"Темпл", 1252.330, -1130.850, -89.084, 1378.330, -1026.330, 110.916},
        {"Маленькая Мексика", 1701.900, -1842.270, -89.084, 1812.620, -1722.260, 110.916},
        {"Квинс", -2411.220, 373.539, 0.000, -2253.540, 458.411, 200.000},
        {"Аэропорт", 1515.810, 1586.400, -12.500, 1729.950, 1714.560, 87.500},
        {"Ричман", 225.165, -1292.070, -89.084, 466.223, -1235.070, 110.916},
        {"Темпл", 1252.330, -1026.330, -89.084, 1391.050, -926.999, 110.916},
        {"Восточный ЛС", 2266.260, -1494.030, -89.084, 2381.680, -1372.040, 110.916},
        {"Воссточное шоссе", 2623.180, 943.235, -89.084, 2749.900, 1055.960, 110.916},
        {"Уиллоуфилд", 2541.700, -1941.400, -89.084, 2703.580, -1852.870, 110.916},
        {"Лас-Колинас", 2056.860, -1126.320, -89.084, 2126.860, -920.815, 110.916},
        {"Воссточное шоссе", 2625.160, 2202.760, -89.084, 2685.160, 2442.550, 110.916},
        {"Родео", 225.165, -1501.950, -89.084, 334.503, -1369.620, 110.916},
        {"Лас-Брухас", -365.167, 2123.010, -3.0, -208.570, 2217.680, 200.000},
        {"Воссточное шоссе", 2536.430, 2442.550, -89.084, 2685.160, 2542.550, 110.916},
        {"Родео", 334.503, -1406.050, -89.084, 466.223, -1292.070, 110.916},
        {"Вайнвуд", 647.557, -1227.280, -89.084, 787.461, -1118.280, 110.916},
        {"Родео", 422.680, -1684.650, -89.084, 558.099, -1570.200, 110.916},
        {"Северное шоссе", 2498.210, 2542.550, -89.084, 2685.160, 2626.550, 110.916},
        {"Деловой район", 1724.760, -1430.870, -89.084, 1812.620, -1250.900, 110.916},
        {"Родео", 225.165, -1684.650, -89.084, 312.803, -1501.950, 110.916},
        {"Джефферсон", 2056.860, -1449.670, -89.084, 2266.210, -1372.040, 110.916},
        {"Хэмптон-Барнс", 603.035, 264.312, 0.000, 761.994, 366.572, 200.000},
        {"Темпл", 1096.470, -1130.840, -89.084, 1252.330, -1026.330, 110.916},
        {"Мост Кинкейд", -1087.930, 855.370, -89.084, -961.950, 986.281, 110.916},
        {"Пляж Верона", 1046.150, -1722.260, -89.084, 1161.520, -1577.590, 110.916},
        {"Коммерческий район", 1323.900, -1722.260, -89.084, 1440.900, -1577.590, 110.916},
        {"Малхолланд", 1357.000, -926.999, -89.084, 1463.900, -768.027, 110.916},
        {"Родео", 466.223, -1570.200, -89.084, 558.099, -1385.070, 110.916},
        {"Малхолланд", 911.802, -860.619, -89.084, 1096.470, -768.027, 110.916},
        {"Малхолланд", 768.694, -954.662, -89.084, 952.604, -860.619, 110.916},
        {"Южное шоссе", 2377.390, 788.894, -89.084, 2537.390, 897.901, 110.916},
        {"Айдлвуд", 1812.620, -1852.870, -89.084, 1971.660, -1742.310, 110.916},
        {"Океанские доки", 2089.000, -2394.330, -89.084, 2201.820, -2235.840, 110.916},
        {"Коммерческий район", 1370.850, -1577.590, -89.084, 1463.900, -1384.950, 110.916},
        {"Северное шоссе", 2121.400, 2508.230, -89.084, 2237.400, 2663.170, 110.916},
        {"Темпл", 1096.470, -1026.330, -89.084, 1252.330, -910.170, 110.916},
        {"Глен Парк", 1812.620, -1449.670, -89.084, 1996.910, -1350.720, 110.916},
        {"Аэропорт Истер-Бэй", -1242.980, -50.096, 0.000, -1213.910, 578.396, 200.000},
        {"Мост Мартин", -222.179, 293.324, 0.000, -122.126, 476.465, 200.000},
        {"Стрип", 2106.700, 1863.230, -89.084, 2162.390, 2202.760, 110.916},
        {"Уиллоуфилд", 2541.700, -2059.230, -89.084, 2703.580, -1941.400, 110.916},
        {"Канал Марина", 807.922, -1577.590, -89.084, 926.922, -1416.250, 110.916},
        {"Аэропорт", 1457.370, 1143.210, -89.084, 1777.400, 1203.280, 110.916},
        {"Айдлвуд", 1812.620, -1742.310, -89.084, 1951.660, -1602.310, 110.916},
        {"Восточная Эспаланда", -1580.010, 1025.980, -6.1, -1499.890, 1274.260, 200.000},
        {"Деловой район", 1370.850, -1384.950, -89.084, 1463.900, -1170.870, 110.916},
        {"Мост Мако", 1664.620, 401.750, 0.000, 1785.140, 567.203, 200.000},
        {"Родео", 312.803, -1684.650, -89.084, 422.680, -1501.950, 110.916},
        {"Площадь Першинг", 1440.900, -1722.260, -89.084, 1583.500, -1577.590, 110.916},
        {"Малхолланд", 687.802, -860.619, -89.084, 911.802, -768.027, 110.916},
        {"Мост Гант", -2741.070, 1490.470, -6.1, -2616.400, 1659.680, 200.000},
        {"Лас-Колинас", 2185.330, -1154.590, -89.084, 2281.450, -934.489, 110.916},
        {"Малхолланд", 1169.130, -910.170, -89.084, 1318.130, -768.027, 110.916},
        {"Северное шоссе", 1938.800, 2508.230, -89.084, 2121.400, 2624.230, 110.916},
        {"Коммерческий район", 1667.960, -1577.590, -89.084, 1812.620, -1430.870, 110.916},
        {"Родео", 72.648, -1544.170, -89.084, 225.165, -1404.970, 110.916},
        {"Рока-Эскаланте", 2536.430, 2202.760, -89.084, 2625.160, 2442.550, 110.916},
        {"Родео", 72.648, -1684.650, -89.084, 225.165, -1544.170, 110.916},
        {"Центральный Рынок", 952.663, -1310.210, -89.084, 1072.660, -1130.850, 110.916},
        {"Лас-Колинас", 2632.740, -1135.040, -89.084, 2747.740, -945.035, 110.916},
        {"Малхолланд", 861.085, -674.885, -89.084, 1156.550, -600.896, 110.916},
        {"Кингс", -2253.540, 373.539, -9.1, -1993.280, 458.411, 200.000},
        {"Восточный Рэдсэндс", 1848.400, 2342.830, -89.084, 2011.940, 2478.490, 110.916},
        {"Деловой район", -1580.010, 744.267, -6.1, -1499.890, 1025.980, 200.000},
        {"Конференц Центр", 1046.150, -1804.210, -89.084, 1323.900, -1722.260, 110.916},
        {"Ричман", 647.557, -1118.280, -89.084, 787.461, -954.662, 110.916},
        {"Оушен-Флэтс", -2994.490, 277.411, -9.1, -2867.850, 458.411, 200.000},
        {"Колледж Грингласс", 964.391, 930.890, -89.084, 1166.530, 1044.690, 110.916},
        {"Глен Парк", 1812.620, -1100.820, -89.084, 1994.330, -973.380, 110.916},
        {"Грузовое депо", 1375.600, 919.447, -89.084, 1457.370, 1203.280, 110.916},
        {"Регьюлар-Том", -405.770, 1712.860, -3.0, -276.719, 1892.750, 200.000},
        {"Пляж Верона", 1161.520, -1722.260, -89.084, 1323.900, -1577.590, 110.916},
        {"Восточный ЛС", 2281.450, -1372.040, -89.084, 2381.680, -1135.040, 110.916},
        {"Дворец Калигулы", 2137.400, 1703.230, -89.084, 2437.390, 1783.230, 110.916},
        {"Айдлвуд", 1951.660, -1742.310, -89.084, 2124.660, -1602.310, 110.916},
        {"Пилигрим", 2624.400, 1383.230, -89.084, 2685.160, 1783.230, 110.916},
        {"Айдлвуд", 2124.660, -1742.310, -89.084, 2222.560, -1494.030, 110.916},
        {"Квинс", -2533.040, 458.411, 0.000, -2329.310, 578.396, 200.000},
        {"Деловой район", -1871.720, 1176.420, -4.5, -1620.300, 1274.260, 200.000},
        {"Коммерческий район", 1583.500, -1722.260, -89.084, 1758.900, -1577.590, 110.916},
        {"Восточный ЛС", 2381.680, -1454.350, -89.084, 2462.130, -1135.040, 110.916},
        {"Канал Марина", 647.712, -1577.590, -89.084, 807.922, -1416.250, 110.916},
        {"Ричман", 72.648, -1404.970, -89.084, 225.165, -1235.070, 110.916},
        {"Вайнвуд", 647.712, -1416.250, -89.084, 787.461, -1227.280, 110.916},
        {"Восточный ЛС", 2222.560, -1628.530, -89.084, 2421.030, -1494.030, 110.916},
        {"Родео", 558.099, -1684.650, -89.084, 647.522, -1384.930, 110.916},
        {"Истерский Тоннель", -1709.710, -833.034, -1.5, -1446.010, -730.118, 200.000},
        {"Родео", 466.223, -1385.070, -89.084, 647.522, -1235.070, 110.916},
        {"Восточный Рэдсэндс", 1817.390, 2202.760, -89.084, 2011.940, 2342.830, 110.916},
        {"Казино", 2162.390, 1783.230, -89.084, 2437.390, 1883.230, 110.916},
        {"Айдлвуд", 1971.660, -1852.870, -89.084, 2222.560, -1742.310, 110.916},
        {"Пересечение Монтгомери", 1546.650, 208.164, 0.000, 1745.830, 347.457, 200.000},
        {"Уиллоуфилд", 2089.000, -2235.840, -89.084, 2201.820, -1989.900, 110.916},
        {"Темпл", 952.663, -1130.840, -89.084, 1096.470, -937.184, 110.916},
        {"Прикл-Пайн", 1848.400, 2553.490, -89.084, 1938.800, 2863.230, 110.916},
        {"Аэропорт", 1400.970, -2669.260, -39.084, 2189.820, -2597.260, 60.916},
        {"Мост Гарвер", -1213.910, 950.022, -89.084, -1087.930, 1178.930, 110.916},
        {"Мост Гарвер", -1339.890, 828.129, -89.084, -1213.910, 1057.040, 110.916},
        {"Мост Кинкейд", -1339.890, 599.218, -89.084, -1213.910, 828.129, 110.916},
        {"Мост Кинкейд", -1213.910, 721.111, -89.084, -1087.930, 950.022, 110.916},
        {"Пляж Верона", 930.221, -2006.780, -89.084, 1073.220, -1804.210, 110.916},
        {"Обсерватория", 1073.220, -2006.780, -89.084, 1249.620, -1842.270, 110.916},
        {"Гора Вайнвуд", 787.461, -1130.840, -89.084, 952.604, -954.662, 110.916},
        {"Гора Вайнвуд", 787.461, -1310.210, -89.084, 952.663, -1130.840, 110.916},
        {"Коммерческий район", 1463.900, -1577.590, -89.084, 1667.960, -1430.870, 110.916},
        {"Центральный Рынок", 787.461, -1416.250, -89.084, 1072.660, -1310.210, 110.916},
        {"Западный Рокшор", 2377.390, 596.349, -89.084, 2537.390, 788.894, 110.916},
        {"Северное шоссе", 2237.400, 2542.550, -89.084, 2498.210, 2663.170, 110.916},
        {"Восточный пляж", 2632.830, -1668.130, -89.084, 2747.740, -1393.420, 110.916},
        {"Мост Фаллоу", 434.341, 366.572, 0.000, 603.035, 555.680, 200.000},
        {"Уиллоуфилд", 2089.000, -1989.900, -89.084, 2324.000, -1852.870, 110.916},
        {"Чайнатаун", -2274.170, 578.396, -7.6, -2078.670, 744.170, 200.000},
        {"Скалистый массив", -208.570, 2337.180, 0.000, 8.430, 2487.180, 200.000},
        {"Океанские доки", 2324.000, -2145.100, -89.084, 2703.580, -2059.230, 110.916},
        {"Химзавод Истер-Бэй", -1132.820, -768.027, 0.000, -956.476, -578.118, 200.000},
        {"Казино Визаж", 1817.390, 1703.230, -89.084, 2027.400, 1863.230, 110.916},
        {"Оушен-Флэтс", -2994.490, -430.276, -1.2, -2831.890, -222.589, 200.000},
        {"Ричман", 321.356, -860.619, -89.084, 687.802, -768.027, 110.916},
        {"Нефтяной комплекс", 176.581, 1305.450, -3.0, 338.658, 1520.720, 200.000},
        {"Ричман", 321.356, -768.027, -89.084, 700.794, -674.885, 110.916},
        {"Казино", 2162.390, 1883.230, -89.084, 2437.390, 2012.180, 110.916},
        {"Восточный пляж", 2747.740, -1668.130, -89.084, 2959.350, -1498.620, 110.916},
        {"Джефферсон", 2056.860, -1372.040, -89.084, 2281.450, -1210.740, 110.916},
        {"Деловой район", 1463.900, -1290.870, -89.084, 1724.760, -1150.870, 110.916},
        {"Деловой район", 1463.900, -1430.870, -89.084, 1724.760, -1290.870, 110.916},
        {"Мост Гарвер", -1499.890, 696.442, -179.615, -1339.890, 925.353, 20.385},
        {"Южное шоссе", 1457.390, 823.228, -89.084, 2377.390, 863.229, 110.916},
        {"Восточный ЛС", 2421.030, -1628.530, -89.084, 2632.830, -1454.350, 110.916},
        {"Колледж Грингласс", 964.391, 1044.690, -89.084, 1197.390, 1203.220, 110.916},
        {"Лас-Колинас", 2747.740, -1120.040, -89.084, 2959.350, -945.035, 110.916},
        {"Малхолланд", 737.573, -768.027, -89.084, 1142.290, -674.885, 110.916},
        {"Океанские доки", 2201.820, -2730.880, -89.084, 2324.000, -2418.330, 110.916},
        {"Восточный ЛС", 2462.130, -1454.350, -89.084, 2581.730, -1135.040, 110.916},
        {"Гантон", 2222.560, -1722.330, -89.084, 2632.830, -1628.530, 110.916},
        {"Клуб Ависпа", -2831.890, -430.276, -6.1, -2646.400, -222.589, 200.000},
        {"Уиллоуфилд", 1970.620, -2179.250, -89.084, 2089.000, -1852.870, 110.916},
        {"Северная Эспланада", -1982.320, 1274.260, -4.5, -1524.240, 1358.900, 200.000},
        {"Казино Хай-Роллер", 1817.390, 1283.230, -89.084, 2027.390, 1469.230, 110.916},
        {"Океанские доки", 2201.820, -2418.330, -89.084, 2324.000, -2095.000, 110.916},
        {"Мотель", 1823.080, 596.349, -89.084, 1997.220, 823.228, 110.916},
        {"Бэйсайнд-Марина", -2353.170, 2275.790, 0.000, -2153.170, 2475.790, 200.000},
        {"Кингс", -2329.310, 458.411, -7.6, -1993.280, 578.396, 200.000},
        {"Эль-Корона", 1692.620, -2179.250, -89.084, 1812.620, -1842.270, 110.916},
        {"Часовня Блэкфилд", 1375.600, 596.349, -89.084, 1558.090, 823.228, 110.916},
        {"Розовый лебедь", 1817.390, 1083.230, -89.084, 2027.390, 1283.230, 110.916},
        {"Западное шоссе", 1197.390, 1163.390, -89.084, 1236.630, 2243.230, 110.916},
        {"Лос-Флорес", 2581.730, -1393.420, -89.084, 2747.740, -1135.040, 110.916},
        {"Казино Визаж", 1817.390, 1863.230, -89.084, 2106.700, 2011.830, 110.916},
        {"Прикл-Пайн", 1938.800, 2624.230, -89.084, 2121.400, 2861.550, 110.916},
        {"Пляж Верона", 851.449, -1804.210, -89.084, 1046.150, -1577.590, 110.916},
        {"Пересечение Робада", -1119.010, 1178.930, -89.084, -862.025, 1351.450, 110.916},
        {"Линден-Сайд", 2749.900, 943.235, -89.084, 2923.390, 1198.990, 110.916},
        {"Океанские доки", 2703.580, -2302.330, -89.084, 2959.350, -2126.900, 110.916},
        {"Уиллоуфилд", 2324.000, -2059.230, -89.084, 2541.700, -1852.870, 110.916},
        {"Кингс", -2411.220, 265.243, -9.1, -1993.280, 373.539, 200.000},
        {"Коммерческий район", 1323.900, -1842.270, -89.084, 1701.900, -1722.260, 110.916},
        {"Малхолланд", 1269.130, -768.027, -89.084, 1414.070, -452.425, 110.916},
        {"Канал Марина", 647.712, -1804.210, -89.084, 851.449, -1577.590, 110.916},
        {"Бэттери-Пойнт", -2741.070, 1268.410, -4.5, -2533.040, 1490.470, 200.000},
        {"Казино 4 Дракона", 1817.390, 863.232, -89.084, 2027.390, 1083.230, 110.916},
        {"Блэкфилд", 964.391, 1203.220, -89.084, 1197.390, 1403.220, 110.916},
        {"Северное шоссе", 1534.560, 2433.230, -89.084, 1848.400, 2583.230, 110.916},
        {"Поле для гольфа", 1117.400, 2723.230, -89.084, 1457.460, 2863.230, 110.916},
        {"Айдлвуд", 1812.620, -1602.310, -89.084, 2124.660, -1449.670, 110.916},
        {"Западный Рэдсэндс", 1297.470, 2142.860, -89.084, 1777.390, 2243.230, 110.916},
        {"Доэрти", -2270.040, -324.114, -1.2, -1794.920, -222.589, 200.000},
        {"Ферма Хиллтоп", 967.383, -450.390, -3.0, 1176.780, -217.900, 200.000},
        {"Лас-Барранкас", -926.130, 1398.730, -3.0, -719.234, 1634.690, 200.000},
        {"Казино Пираты", 1817.390, 1469.230, -89.084, 2027.400, 1703.230, 110.916},
        {"Сити Холл", -2867.850, 277.411, -9.1, -2593.440, 458.411, 200.000},
        {"Клуб Ависпа", -2646.400, -355.493, 0.000, -2270.040, -222.589, 200.000},
        {"Стрип", 2027.400, 863.229, -89.084, 2087.390, 1703.230, 110.916},
        {"Хашбери", -2593.440, -222.589, -1.0, -2411.220, 54.722, 200.000},
        {"Аэропорт", 1852.000, -2394.330, -89.084, 2089.000, -2179.250, 110.916},
        {"Уайтвуд-Истейтс", 1098.310, 1726.220, -89.084, 1197.390, 2243.230, 110.916},
        {"Водохранилище", -789.737, 1659.680, -89.084, -599.505, 1929.410, 110.916},
        {"Эль-Корона", 1812.620, -2179.250, -89.084, 1970.620, -1852.870, 110.916},
        {"Деловой район", -1700.010, 744.267, -6.1, -1580.010, 1176.520, 200.000},
        {"Долина Фостер", -2178.690, -1250.970, 0.000, -1794.920, -1115.580, 200.000},
        {"Лас-Паясадас", -354.332, 2580.360, 2.0, -133.625, 2816.820, 200.000},
        {"Долина Окультадо", -936.668, 2611.440, 2.0, -715.961, 2847.900, 200.000},
        {"Пересечение Блэкфилд", 1166.530, 795.010, -89.084, 1375.600, 1044.690, 110.916},
        {"Гантон", 2222.560, -1852.870, -89.084, 2632.830, -1722.330, 110.916},
        {"Аэропорт Истер-Бэй", -1213.910, -730.118, 0.000, -1132.820, -50.096, 200.000},
        {"Восточный Рэдсэндс", 1817.390, 2011.830, -89.084, 2106.700, 2202.760, 110.916},
        {"Восточная Эспаланда", -1499.890, 578.396, -79.615, -1339.890, 1274.260, 20.385},
        {"Дворец Калигулы", 2087.390, 1543.230, -89.084, 2437.390, 1703.230, 110.916},
        {"Казино Рояль", 2087.390, 1383.230, -89.084, 2437.390, 1543.230, 110.916},
        {"Ричман", 72.648, -1235.070, -89.084, 321.356, -1008.150, 110.916},
        {"Казино", 2437.390, 1783.230, -89.084, 2685.160, 2012.180, 110.916},
        {"Малхолланд", 1281.130, -452.425, -89.084, 1641.130, -290.913, 110.916},
        {"Деловой район", -1982.320, 744.170, -6.1, -1871.720, 1274.260, 200.000},
        {"Ханки-Панки-Пойнт", 2576.920, 62.158, 0.000, 2759.250, 385.503, 200.000},
        {"Военный склад топлива", 2498.210, 2626.550, -89.084, 2749.900, 2861.550, 110.916},
        {"Шоссе Гарри-Голд", 1777.390, 863.232, -89.084, 1817.390, 2342.830, 110.916},
        {"Тоннель Бэйсайд", -2290.190, 2548.290, -89.084, -1950.190, 2723.290, 110.916},
        {"Океанские доки", 2324.000, -2302.330, -89.084, 2703.580, -2145.100, 110.916},
        {"Ричман", 321.356, -1044.070, -89.084, 647.557, -860.619, 110.916},
        {"Промсклад Рэндольфа", 1558.090, 596.349, -89.084, 1823.080, 823.235, 110.916},
        {"Восточный пляж", 2632.830, -1852.870, -89.084, 2959.350, -1668.130, 110.916},
        {"Флинт-Уотер", -314.426, -753.874, -89.084, -106.339, -463.073, 110.916},
        {"Блуберри", 19.607, -404.136, 3.8, 349.607, -220.137, 200.000},
        {"Станция Линден", 2749.900, 1198.990, -89.084, 2923.390, 1548.990, 110.916},
        {"Глен Парк", 1812.620, -1350.720, -89.084, 2056.860, -1100.820, 110.916},
        {"Деловой район", -1993.280, 265.243, -9.1, -1794.920, 578.396, 200.000},
        {"Западный Рэдсэндс", 1377.390, 2243.230, -89.084, 1704.590, 2433.230, 110.916},
        {"Ричман", 321.356, -1235.070, -89.084, 647.522, -1044.070, 110.916},
        {"Мост Гант", -2741.450, 1659.680, -6.1, -2616.400, 2175.150, 200.000},
        {"Бар Probe Inn", -90.218, 1286.850, -3.0, 153.859, 1554.120, 200.000},
        {"Пересечение Флинт", -187.700, -1596.760, -89.084, 17.063, -1276.600, 110.916},
        {"Лас-Колинас", 2281.450, -1135.040, -89.084, 2632.740, -945.035, 110.916},
        {"Собелл-Рейл-Ярдс", 2749.900, 1548.990, -89.084, 2923.390, 1937.250, 110.916},
        {"Изумрудный остров", 2011.940, 2202.760, -89.084, 2237.400, 2508.230, 110.916},
        {"Скалистый массив", -208.570, 2123.010, -7.6, 114.033, 2337.180, 200.000},
        {"Санта-Флора", -2741.070, 458.411, -7.6, -2533.040, 793.411, 200.000},
        {"Плайя-дель-Севиль", 2703.580, -2126.900, -89.084, 2959.350, -1852.870, 110.916},
        {"Центральный Рынок", 926.922, -1577.590, -89.084, 1370.850, -1416.250, 110.916},
        {"Квинс", -2593.440, 54.722, 0.000, -2411.220, 458.411, 200.000},
        {"Пересечение Пилсон", 1098.390, 2243.230, -89.084, 1377.390, 2507.230, 110.916},
        {"Спинибед", 2121.400, 2663.170, -89.084, 2498.210, 2861.550, 110.916},
        {"Пилигрим", 2437.390, 1383.230, -89.084, 2624.400, 1783.230, 110.916},
        {"Блэкфилд", 964.391, 1403.220, -89.084, 1197.390, 1726.220, 110.916},
        {"Большое ухо", -410.020, 1403.340, -3.0, -137.969, 1681.230, 200.000},
        {"Диллимор", 580.794, -674.885, -9.5, 861.085, -404.790, 200.000},
        {"Эль-Кебрадос", -1645.230, 2498.520, 0.000, -1372.140, 2777.850, 200.000},
        {"Северная Эспланада", -2533.040, 1358.900, -4.5, -1996.660, 1501.210, 200.000},
        {"Аэропорт Истер-Бэй", -1499.890, -50.096, -1.0, -1242.980, 249.904, 200.000},
        {"Рыбацкая лагуна", 1916.990, -233.323, -100.000, 2131.720, 13.800, 200.000},
        {"Малхолланд", 1414.070, -768.027, -89.084, 1667.610, -452.425, 110.916},
        {"Восточный пляж", 2747.740, -1498.620, -89.084, 2959.350, -1120.040, 110.916},
        {"Сан-Андреас Саунд", 2450.390, 385.503, -100.000, 2759.250, 562.349, 200.000},
        {"Тенистые ручьи", -2030.120, -2174.890, -6.1, -1820.640, -1771.660, 200.000},
        {"Центральный Рынок", 1072.660, -1416.250, -89.084, 1370.850, -1130.850, 110.916},
        {"Западный Рокшор", 1997.220, 596.349, -89.084, 2377.390, 823.228, 110.916},
        {"Прикл-Пайн", 1534.560, 2583.230, -89.084, 1848.400, 2863.230, 110.916},
        {"Бухта Пасхи", -1794.920, -50.096, -1.04, -1499.890, 249.904, 200.000},
        {"Лифи-Холлоу", -1166.970, -1856.030, 0.000, -815.624, -1602.070, 200.000},
        {"Грузовое депо", 1457.390, 863.229, -89.084, 1777.400, 1143.210, 110.916},
        {"Прикл-Пайн", 1117.400, 2507.230, -89.084, 1534.560, 2723.230, 110.916},
        {"Блуберри", 104.534, -220.137, 2.3, 349.607, 152.236, 200.000},
        {"Скалистый массив", -464.515, 2217.680, 0.000, -208.570, 2580.360, 200.000},
        {"Деловой район", -2078.670, 578.396, -7.6, -1499.890, 744.267, 200.000},
        {"Восточный Рокшор", 2537.390, 676.549, -89.084, 2902.350, 943.235, 110.916},
        {"Залив Сан-Фиерро", -2616.400, 1501.210, -3.0, -1996.660, 1659.680, 200.000},
        {"Парадизо", -2741.070, 793.411, -6.1, -2533.040, 1268.410, 200.000},
        {"Казино", 2087.390, 1203.230, -89.084, 2640.400, 1383.230, 110.916},
        {"Олд-Вентурас-Стрип", 2162.390, 2012.180, -89.084, 2685.160, 2202.760, 110.916},
        {"Джанипер-Хилл", -2533.040, 578.396, -7.6, -2274.170, 968.369, 200.000},
        {"Джанипер-Холлоу", -2533.040, 968.369, -6.1, -2274.170, 1358.900, 200.000},
        {"Рока-Эскаланте", 2237.400, 2202.760, -89.084, 2536.430, 2542.550, 110.916},
        {"Воссточное шоссе", 2685.160, 1055.960, -89.084, 2749.900, 2626.550, 110.916},
        {"Пляж Верона", 647.712, -2173.290, -89.084, 930.221, -1804.210, 110.916},
        {"Долина Фостер", -2178.690, -599.884, -1.2, -1794.920, -324.114, 200.000},
        {"Арко-дель-Оэсте", -901.129, 2221.860, 0.000, -592.090, 2571.970, 200.000},
        {"Упавшее дерево", -792.254, -698.555, -5.3, -452.404, -380.043, 200.000},
        {"Ферма", -1209.670, -1317.100, 114.981, -908.161, -787.391, 251.981},
        {"Дамба Шермана", -968.772, 1929.410, -3.0, -481.126, 2155.260, 200.000},
        {"Северная Эспланада", -1996.660, 1358.900, -4.5, -1524.240, 1592.510, 200.000},
        {"Финансовый район", -1871.720, 744.170, -6.1, -1701.300, 1176.420, 300.000},
        {"Гарсия", -2411.220, -222.589, -1.14, -2173.040, 265.243, 200.000},
        {"Монтгомери", 1119.510, 119.526, -3.0, 1451.400, 493.323, 200.000},
        {"Крик", 2749.900, 1937.250, -89.084, 2921.620, 2669.790, 110.916},
        {"Аэропорт", 1249.620, -2394.330, -89.084, 1852.000, -2179.250, 110.916},
        {"Пляж Санта-Мария", 72.648, -2173.290, -89.084, 342.648, -1684.650, 110.916},
        {"Пересечение Малхолланд", 1463.900, -1150.870, -89.084, 1812.620, -768.027, 110.916},
        {"Эйнджел-Пайн", -2324.940, -2584.290, -6.1, -1964.220, -2212.110, 200.000},
        {"Вёрдант-Медоус", 37.032, 2337.180, -3.0, 435.988, 2677.900, 200.000},
        {"Октан-Спрингс", 338.658, 1228.510, 0.000, 664.308, 1655.050, 200.000},
        {"Казино Кам-э-Лот", 2087.390, 943.235, -89.084, 2623.180, 1203.230, 110.916},
        {"Западный Рэдсэндс", 1236.630, 1883.110, -89.084, 1777.390, 2142.860, 110.916},
        {"Пляж Санта-Мария", 342.648, -2173.290, -89.084, 647.712, -1684.650, 110.916},
        {"Обсерватория", 1249.620, -2179.250, -89.084, 1692.620, -1842.270, 110.916},
        {"Аэропорт", 1236.630, 1203.280, -89.084, 1457.370, 1883.110, 110.916},
        {"Округ Флинт", -594.191, -1648.550, 0.000, -187.700, -1276.600, 200.000},
        {"Обсерватория", 930.221, -2488.420, -89.084, 1249.620, -2006.780, 110.916},
        {"Паломино Крик", 2160.220, -149.004, 0.000, 2576.920, 228.322, 200.000},
        {"Океанские доки", 2373.770, -2697.090, -89.084, 2809.220, -2330.460, 110.916},
        {"Аэропорт Истер-Бэй", -1213.910, -50.096, -4.5, -947.980, 578.396, 200.000},
        {"Уайтвуд-Истейтс", 883.308, 1726.220, -89.084, 1098.310, 2507.230, 110.916},
        {"Калтон-Хайтс", -2274.170, 744.170, -6.1, -1982.320, 1358.900, 200.000},
        {"Бухта Пасхи", -1794.920, 249.904, -9.1, -1242.980, 578.396, 200.000},
        {"Залив ЛС", -321.744, -2224.430, -89.084, 44.615, -1724.430, 110.916},
        {"Доэрти", -2173.040, -222.589, -1.0, -1794.920, 265.243, 200.000},
        {"Гора Чилиад", -2178.690, -2189.910, -47.917, -2030.120, -1771.660, 576.083},
        {"Форт-Карсон", -376.233, 826.326, -3.0, 123.717, 1220.440, 200.000},
        {"Долина Фостер", -2178.690, -1115.580, 0.000, -1794.920, -599.884, 200.000},
        {"Оушен-Флэтс", -2994.490, -222.589, -1.0, -2593.440, 277.411, 200.000},
        {"Ферн-Ридж", 508.189, -139.259, 0.000, 1306.660, 119.526, 200.000},
        {"Бэйсайд", -2741.070, 2175.150, 0.000, -2353.170, 2722.790, 200.000},
        {"Аэропорт", 1457.370, 1203.280, -89.084, 1777.390, 1883.110, 110.916},
        {"Поместье Блуберри", -319.676, -220.137, 0.000, 104.534, 293.324, 200.000},
        {"Пэлисейдс", -2994.490, 458.411, -6.1, -2741.070, 1339.610, 200.000},
        {"Норт-Рок", 2285.370, -768.027, 0.000, 2770.590, -269.740, 200.000},
        {"Карьер Хантер", 337.244, 710.840, -115.239, 860.554, 1031.710, 203.761},
        {"Аэропорт", 1382.730, -2730.880, -89.084, 2201.820, -2394.330, 110.916},
        {"Миссионер-Хилл", -2994.490, -811.276, 0.000, -2178.690, -430.276, 200.000},
        {"Залив СФ", -2616.400, 1659.680, -3.0, -1996.660, 2175.150, 200.000},
        {"Запретная Зона", -91.586, 1655.050, -50.000, 421.234, 2123.010, 250.000},
        {"Гора Чилиад", -2997.470, -1115.580, -47.917, -2178.690, -971.913, 576.083},
        {"Гора Чилиад", -2178.690, -1771.660, -47.917, -1936.120, -1250.970, 576.083},
        {"Аэропорт Истер-Бэй", -1794.920, -730.118, -3.0, -1213.910, -50.096, 200.000},
        {"Паноптикум", -947.980, -304.320, -1.1, -319.676, 327.071, 200.000},
        {"Тенистые ручьи", -1820.640, -2643.680, -8.0, -1226.780, -1771.660, 200.000},
        {"Бэк-о-Бейонд", -1166.970, -2641.190, 0.000, -321.744, -1856.030, 200.000},
        {"Гора Чилиад", -2994.490, -2189.910, -47.917, -2178.690, -1115.580, 576.083},
        {"Тьерра Робада", -1213.910, 596.349, -242.990, -480.539, 1659.680, 900.000},
        {"Округ Флинт", -1213.910, -2892.970, -242.990, 44.615, -768.027, 900.000},
        {"Уэтстоун", -2997.470, -2892.970, -242.990, -1213.910, -1115.580, 900.000},
        {"Пустынный округ", -480.539, 596.349, -242.990, 869.461, 2993.870, 900.000},
        {"Тьерра Робада", -2997.470, 1659.680, -242.990, -480.539, 2993.870, 900.000},
        {"Окружность СФ", -2997.470, -1115.580, -242.990, -1213.910, 1659.680, 900.000},
        {"Окружность ЛВ", 869.461, 596.349, -242.990, 2997.060, 2993.870, 900.000},
        {"Туманный округ", -1213.910, -768.027, -242.990, 2997.060, 596.349, 900.000},
        {"Окружность ЛС", 44.615, -2892.970, -242.990, 2997.060, -768.027, 900.000}
    }
    for i, v in ipairs(streets) do
        if (x >= v[2]) and (y >= v[3]) and (z >= v[4]) and (x <= v[5]) and (y <= v[6]) and (z <= v[7]) then
            return v[1]
        end
    end
    return 'Неизвестно'
end
function argbToRgbNormalized(argb)
    local a = math.floor(argb / 0x1000000) % 0x100
    local r = math.floor(argb / 0x10000) % 0x100
    local g = math.floor(argb / 0x100) % 0x100
    local b = argb % 0x100
    local normalizedR = r / 255.0
    local normalizedG = g / 255.0
    local normalizedB = b / 255.0
    return {normalizedR, normalizedG, normalizedB}
end
function getARZServerNumber()
	local server = 0
	local servers = {
		{name = 'Phoenix', number = '01'},
		{name = 'Tucson', number = '02'},
		{name = 'Scottdale', number = '03'},
		{name = 'Chandler', number = '04'},
		{name = 'Brainburg', number = '05'},
		{name = 'Saint%-Rose', number = '06'},
		{name = 'Mesa', number = '07'},
		{name = 'Red%-Rock', number = '08'},
		{name = 'Yuma', number = '09'},
		{name = 'Surprise', number = '10'},
		{name = 'Prescott', number = '11'},
		{name = 'Glendale', number = '12'},
		{name = 'Kingman', number = '13'},
		{name = 'Winslow', number = '14'},
		{name = 'Payson', number = '15'},
		{name = 'Gilbert', number = '16'},
		{name = 'Show Low', number = '17'},
		{name = 'Casa%-Grande', number = '18'},
		{name = 'Page', number = '19'},
		{name = 'Sun%-City', number = '20'},
		{name = 'Queen%-Creek', number = '21'},
		{name = 'Sedona', number = '22'},
		{name = 'Holiday', number = '23'},
		{name = 'Wednesday', number = '24'},
		{name = 'Yava', number = '25'},
		{name = 'Faraway', number = '26'},
		{name = 'Bumble Bee', number = '27'},
		{name = 'Christmas', number = '28'},
		{name = 'Mirage', number = '29'},
		{name = 'Love', number = '30'},
		{name = 'Mobile III', number = '103'},
		{name = 'Mobile II', number = '102'},
		{name = 'Mobile I', number = '101'},
	}
	for _, s in ipairs(servers) do
		if sampGetCurrentServerName():find(s.name) then
			server = s.number
			break
		end
	end
	return server
end
function check_update()
	print('[Justice Helper] Начинаю проверку на наличие обновлений...')
	sampAddChatMessage('[Justice Helper] {ffffff}Начинаю проверку на наличие обновлений...', message_color)
	local path = configDirectory .. "/Update_Info.json"
	os.remove(path)
	local url = 'https://raw.githubusercontent.com/wol1den/Justice-Helper-by-bhoped/main/Update_Info.json'
	if isMonetLoader() then
		downloadToFile(url, path, function(type, pos, total_size)
			if type == "finished" then
				local updateInfo = readJsonFile(path)
				if updateInfo then
					local uVer = updateInfo.current_version
					local uUrl = updateInfo.update_url
					local uText = updateInfo.update_info
					print("[Justice Helper] Текущая установленная версия:", thisScript().version)
					print("[Justice Helper] Текущая версия в облаке:", uVer)
					if thisScript().version ~= uVer then
						print('[Justice Helper] Доступно обновление!')
						sampAddChatMessage('[Justice Helper] {ffffff}Доступно обновление!', message_color)
						need_update_helper = true
						updateUrl = uUrl
						updateVer = uVer
						updateInfoText = uText
						UpdateWindow[0] = true
					else
						print('[Justice Helper] Обновление не нужно!')
						sampAddChatMessage('[Justice Helper] {ffffff}Обновление не нужно, у вас актуальная версия!', message_color)
					end
				end
			end
		end)
	else
		downloadUrlToFile(url, path, function(id, status)
			if status == 6 then -- ENDDOWNLOADDATA
				local updateInfo = readJsonFile(path)
				if updateInfo then
					local uVer = updateInfo.current_version
					local uUrl = updateInfo.update_url
					local uText = updateInfo.update_info
					print("[Justice Helper] Текущая установленная версия:", thisScript().version)
					print("[Justice Helper] Текущая версия в облаке:", uVer)
					if thisScript().version ~= uVer then
						print('[Justice Helper] Доступно обновление!')
						sampAddChatMessage('[Justice Helper] {ffffff}Доступно обновление!', message_color)
						need_update_helper = true
						updateUrl = uUrl
						updateVer = uVer
						updateInfoText = uText
						UpdateWindow[0] = true
					else
						print('[Justice Helper] Обновление не нужно!')
						sampAddChatMessage('[Justice Helper] {ffffff}Обновление не нужно, у вас актуальная версия!', message_color)
					end
				end
			end
		end)
	end
	function readJsonFile(filePath)
		if not doesFileExist(filePath) then
			print("[Justice Helper] Ошибка: Файл " .. filePath .. " не существует")
			return nil
		end
		local file = io.open(filePath, "r")
		local content = file:read("*a")
		file:close()
		local jsonData = decodeJson(content)
		if not jsonData then
			print("[Justice Helper] Ошибка: Неверный формат JSON в файле " .. filePath)
			return nil
		end
		return jsonData
	end
end
function downloadToFile(url, path, callback, progressInterval)
	callback = callback or function() end
	progressInterval = progressInterval or 0.1

	local effil = require("effil")
	local progressChannel = effil.channel(0)

	local runner = effil.thread(function(url, path)
	local http = require("socket.http")
	local ltn = require("ltn12")

	local r, c, h = http.request({
		method = "HEAD",
		url = url,
	})

	if c ~= 200 then
		return false, c
	end
	local total_size = h["content-length"]

	local f = io.open(path, "wb")
	if not f then
		return false, "failed to open file"
	end
	local success, res, status_code = pcall(http.request, {
		method = "GET",
		url = url,
		sink = function(chunk, err)
		local clock = os.clock()
		if chunk and not lastProgress or (clock - lastProgress) >= progressInterval then
			progressChannel:push("downloading", f:seek("end"), total_size)
			lastProgress = os.clock()
		elseif err then
			progressChannel:push("error", err)
		end

		return ltn.sink.file(f)(chunk, err)
		end,
	})

	if not success then
		return false, res
	end

	if not res then
		return false, status_code
	end

	return true, total_size
	end)
	local thread = runner(url, path)

	local function checkStatus()
	local tstatus = thread:status()
	if tstatus == "failed" or tstatus == "completed" then
		local result, value = thread:get()

		if result then
		callback("finished", value)
		else
		callback("error", value)
		end

		return true
	end
	end

	lua_thread.create(function()
	if checkStatus() then
		return
	end

	while thread:status() == "running" do
		if progressChannel:size() > 0 then
		local type, pos, total_size = progressChannel:pop()
		callback(type, pos, total_size)
		end
		wait(0)
	end

	checkStatus()
	end)
end
function downloadFileFromUrlToPath(url, path)
	print('[Justice Helper] Начинаю скачивание файла в ' .. path)
	if isMonetLoader() then
		downloadToFile(url, path, function(type, pos, total_size)
			if type == "downloading" then
				--print(("Скачивание %d/%d"):format(pos, total_size))
			elseif type == "finished" then
				if download_helper then
					sampAddChatMessage('[Justice Helper] {ffffff}Загрузка новой версии хелпера заверешна успешно! Перезагрузка..',  message_color)
					reload_script = true
					thisScript():unload()
				elseif download_smartuk then
					sampAddChatMessage('[Justice Helper] {ffffff}Загрузка умной выдачи розыска для ' .. getARZServerNumber() ..  ' сервера заверешна успешно!',  message_color)
					download_smartuk = false
					load_smart_uk()
				elseif download_smartpdd then
					sampAddChatMessage('[Justice Helper] {ffffff}Загрузка умной выдачи штрафов для ' .. getARZServerNumber() ..  ' сервера заверешна успешно!',  message_color)
					download_smartpdd = false
					load_smart_pdd()
				elseif download_arzvehicles then
					sampAddChatMessage('[Justice Helper] {ffffff}Загрузка списка моделей кастом каров аризоны заверешена успешно!',  message_color)
					download_arzvehicles = false
					load_arzvehicles()
				end
			elseif type == "error" then
				sampAddChatMessage('[Justice Helper] {ffffff}Ошибка загрузки: ' .. pos,  message_color)
			end
		end)
	else
		downloadUrlToFile(url, path, function(id, status)
			if status == 6 then -- ENDDOWNLOADDATA
				if download_helper then
					sampAddChatMessage('[Justice Helper] {ffffff}Загрузка новой версии хелпера заверешна успешно! Перезагрузка..',  message_color)
					reload_script = true
					thisScript():unload()
				elseif download_smartuk then
					sampAddChatMessage('[Justice Helper] {ffffff}Загрузка умной выдачи розыска для ' .. getARZServerNumber() ..  ' сервера заверешна успешно!',  message_color)
					download_smartuk = false
					load_smart_uk()
				elseif download_smartpdd then
					sampAddChatMessage('[Justice Helper] {ffffff}Загрузка умной выдачи штрафов для ' .. getARZServerNumber() ..  ' сервера заверешна успешно!',  message_color)
					download_smartpdd = false
					load_smart_pdd()
				elseif download_arzvehicles then
					sampAddChatMessage('[Justice Helper] {ffffff}Загрузка списка моделей кастом каров аризоны заверешена успешно!',  message_color)
					download_arzvehicles = false
					load_arzvehicles()
				end
			end
		end)
	end
end
function sampev.onShowTextDraw(id, data)
	if data.text:find('~n~~n~~n~~n~~n~~n~~n~~n~~w~Style: ~r~Sport!') then
		sampAddChatMessage('[Justice Helper] {ffffff}Активирован режим езды Sport!', message_color)
		return false
	end
	if data.text:find('~n~~n~~n~~n~~n~~n~~n~~n~~w~Style: ~g~Comfort!') then
		sampAddChatMessage('[Justice Helper] {ffffff}Активирован режим езды Comfort!', message_color)
		return false
	end
end
function sampev.onDisplayGameText(style,time,text)
	if text:find('~n~~n~~n~~n~~n~~n~~n~~n~~w~Style: ~r~Sport!') then
		sampAddChatMessage('[Justice Helper] {ffffff}Активирован режим езды Sport!', message_color)
		return false
	end
	if text:find('~n~~n~~n~~n~~n~~n~~n~~n~~w~Style: ~g~Comfort!') then
		sampAddChatMessage('[Justice Helper] {ffffff}Активирован режим езды Comfort!', message_color)
		return false
	end
end
function sampev.onSendTakeDamage(playerId,damage,weapon)
	if playerId ~= 65535 then
		playerId2 = playerId1
		playerId1 = playerId
		if isParamSampID(playerId) and playerId1 ~= playerId2 and tonumber(playerId) ~= 0 and weapon then
			local weapon_name = weapons.get_name(weapon)
			if weapon_name then
				sampAddChatMessage('[Justice Helper] {ffffff}Игрок ' .. sampGetPlayerNickname(playerId) .. '[' .. playerId .. '] напал на вас используя ' .. weapon_name .. ', ситуационный код изменён на CODE 0.', message_color)
				ComboPatroolCode[0] = 1
				patrool_code = combo_patrool_code_list[ComboPatroolCode[0] + 1]
				if settings.general.auto_doklad_damage then
					sampSendChat('/r ' .. tagReplacements.my_doklad_nick() .. ' на CONTROl. Нахожусь под огнём в районе ' .. tagReplacements.get_area() ..  ' (' .. tagReplacements.get_square() .. '), состояние CODE 0! ')
				end
				table.insert(enemy, 'Игрок ' .. sampGetPlayerNickname(playerId) .. '[' .. playerId .. '] напал на вас используя ' .. weapon_name .. '!')
			end
		end
	end
end
function sampev.onServerMessage(color,text)
	--sampAddChatMessage('color = ' .. color .. ' , text = '..text,-1)
	if (settings.general.auto_uval and tonumber(settings.player_info.fraction_rank_number) >= 9) then
		if text:find("%[(.-)%] (.-) (.-)%[(.-)%]: (.+)") and color == 766526463 then -- /f /fb или /r /rb без тэга 
			local tag, rank, name, playerID, message = string.match(text, "%[(.-)%] (.+) (.-)%[(.-)%]: (.+)")
			if ((not message:find(" отправьте (.+) +++ чтобы уволится ПСЖ!") and not message:find("Сотрудник (.+) был уволен по причине(.+)")) and (message:rupper():find("ПСЖ") or message:rupper():find("ПСЖ.") or message:rupper():find("УВОЛЬТЕ") or message:find("УВОЛЬТЕ.") or message:rupper():find("УВАЛ") or message:rupper():find("УВАЛ."))) then
				message3 = message2
				message2 = message1
				message1 = text
				PlayerID = playerID
				sampAddChatMessage(text, 0xFF2DB043)
				if message3 == text then
					auto_uval_checker = true
					sampSendChat('/fmute ' .. playerID .. ' 1 [AutoUval] Ожидайте...')
				elseif tag == "R" then
					sampSendChat("/rb "..name.." отправьте /rb +++ чтобы уволится ПСЖ!")
				elseif tag == "F" then
					sampSendChat("/fb "..name.." отправьте /fb +++ чтобы уволится ПСЖ!")
				end
			elseif ((message == "(( +++ ))" or message == "(( +++. ))") and (PlayerID == playerID)) then
			 	sampAddChatMessage(text, 0xFF2DB043)
				auto_uval_checker = true
				sampSendChat('/fmute ' .. PlayerID .. ' 1 [AutoUval] Ожидайте...')
			end
		elseif text:find("%[(.-)%] %[(.-)%] (.+) (.-)%[(.-)%]: (.+)") and color == 766526463 then -- /r или /f с тэгом
			local tag, tag2, rank, name, playerID, message = string.match(text, "%[(.-)%] %[(.-)%] (.+) (.-)%[(.-)%]: (.+)")
			if not message:find(" отправьте (.+) +++ чтобы уволится ПСЖ!") and not message:find("Сотрудник (.+) был уволен по причине(.+)") and message:rupper():find("ПСЖ") or message:rupper():find("ПСЖ.") or message:rupper():find("УВОЛЬТЕ") or message:find("УВОЛЬТЕ.") or message:rupper():find("УВАЛ") or message:rupper():find("УВАЛ.") then
				message3 = message2
				message2 = message1
				message1 = text
				PlayerID = playerID	
				sampAddChatMessage(text, 0xFF2DB043)
				if message3 == text then
					auto_uval_checker = true
					sampSendChat('/fmute ' .. playerID .. ' 1 [AutoUval] Ожидайте...')
				elseif tag == "R" then
					sampSendChat("/rb "..name.."["..playerID.."], отправьте /rb +++ чтобы уволится ПСЖ!")
				elseif tag == "F" then
					sampSendChat("/fb "..name.."["..playerID.."], отправьте /fb +++ чтобы уволится ПСЖ!")
				end
			elseif ((message == "(( +++ ))" or  message == "(( +++. ))") and (PlayerID == playerID)) then
				sampAddChatMessage(text, 0xFF2DB043)
				auto_uval_checker = true
				sampSendChat('/fmute ' .. playerID .. ' 1 [AutoUval] Ожидайте...')
			end
		end
		
		if text:find("(.+) заглушил%(а%) игрока (.+) на 1 минут. Причина: %[AutoUval%] Ожидайте...") and auto_uval_checker then
			sampAddChatMessage(text, message_color)
			local Name, PlayerName, Time, Reason = text:match("(.+) заглушил%(а%) игрока (.+) на (%d+) минут. Причина: (.+)")
			local MyName = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
			if Name == MyName then
				sampAddChatMessage('[Justice Helper] {ffffff}Увольняю игрока ' .. sampGetPlayerNickname(PlayerID) .. '!', message_color)
				auto_uval_checker = false
				temp = PlayerID .. ' ПСЖ'
				find_and_use_command("/uninvite {arg_id} {arg2}", temp)
			else
				sampAddChatMessage('[Justice Helper] {ffffff}Другой заместитель/лидер уже увольняет игрока ' .. sampGetPlayerNickname(PlayerID) .. '!', message_color)
				auto_uval_checker = false
			end
		end
	end
	if tonumber(settings.player_info.fraction_rank_number) >= 5 then
		if text:find("%[(.-)%] (.-) (.-)%[(.-)%]: (.+)") and color == 766526463 then -- /f /fb или /r /rb без тэга 
			local tag, rank, name, playerID, message = string.match(text, "%[(.-)%] (.+) (.-)%[(.-)%]: (.+)")
			if message:find('Прошу обьявить в розыск (%d) степени дело N(%d+)%. Причина%: (.+)') then
				local lvl, id, reason = message:match('Прошу обьявить в розыск (%d) степени дело N(%d+)%. Причина%: (.+)')
				form_su = id .. ' ' .. lvl .. ' ' .. reason
				sampAddChatMessage('[Justice Helper] {ffffff}Используйте /givefsu ' .. playerID .. ' чтобы выдать розыск по запросу офицера!', message_color)
			end
		elseif text:find("%[(.-)%] %[(.-)%] (.+) (.-)%[(.-)%]: (.+)") and color == 766526463 then -- /r или /f с тэгом
			local tag, tag2, rank, name, playerID, message = string.match(text, "%[(.-)%] %[(.-)%] (.+) (.-)%[(.-)%]: (.+)")
			local lvl, id, reason = message:match('Прошу обьявить в розыск (%d) степени дело N(%d+)%. Причина%: (.+)')
				form_su = id .. ' ' .. lvl .. ' ' .. reason
				sampAddChatMessage('[Justice Helper] {ffffff}Используйте /givefsu ' .. playerID .. ' чтобы выдать розыск по запросу офицера!', message_color)
		end
	end
	if (text:find("{FFFFFF}(.-) принял ваше предложение вступить к вам в организацию.") and tonumber(settings.player_info.fraction_rank_number) >= 9) then
		sampAddChatMessage(text, 0xFF2DB043)
		local PlayerName = text:match("{FFFFFF}(.-) принял ваше предложение вступить к вам в организацию.")
		sampSendChat("/r "..TranslateNick(PlayerName).." - наш новый сотрудник!")
	end
	if (text:find("У (.+) отсутствует трудовая книжка. Вы можете выдать ему книжку с помощью команды /givewbook") and tonumber(settings.player_info.fraction_rank_number) >= 9) then
		local nick = text:match("У (.+) отсутствует трудовая книжка. Вы можете выдать ему книжку с помощью команды /givewbook")
		local cmd = '/givewbook'
		for _, command in ipairs(commands.commands_manage) do
			if command.enable and command.text:find('/givewbook {arg_id}') then
				cmd =  '/' .. command.cmd
			end
		end
		sampAddChatMessage('[Justice Helper] {ffffff}У игрока ' .. nick .. ' нету трудовой книжки, выдайте её используя ' .. message_color_hex .. cmd .. ' ' .. sampGetPlayerIdByNickname(nick), message_color)
		return false
	end
	if (settings.general.auto_mask) then
		if text:find('Время действия маски истекло, вам пришлось ее выбросить.') then
			sampAddChatMessage('[Justice Helper] {ffffff}Время действия маски истекло, автоматически надеваю новую', message_color)
			sampSendChat("/mask")
			return false
		elseif (text:find('Время действия маски (%d+) минут, после исхода времени ее придётся выбросить.')) then
			local min = text:match('Время действия маски (%d+) минут, после исхода времени ее придётся выбросить.')
			sampAddChatMessage('[Justice Helper] {ffffff}Время действия маски ' .. min .. ' минут, после исхода времени автоматически надеву новую!', message_color)
			return false
		end
	end 
	if text:find("1%.{6495ED} 111 %- {FFFFFF}Проверить баланс телефона") or
		text:find("2%.{6495ED} 060 %- {FFFFFF}Служба точного времени") or
		text:find("3%.{6495ED} 911 %- {FFFFFF}Полицейский участок") or
		text:find("4%.{6495ED} 912 %- {FFFFFF}Скорая помощь") or
		text:find("5%.{6495ED} 914 %- {FFFFFF}Такси") or
		text:find("5%.{6495ED} 914 %- {FFFFFF}Механик") or
		text:find("6%.{6495ED} 8828 %- {FFFFFF}Справочная центрального банка") or
		text:find("7%.{6495ED} 997 %- {FFFFFF}Служба по вопросам жилой недвижимости %(узнать владельца дома%)") then
		return false
	end
	if text:find("Номера телефонов государственных служб:") then
		sampAddChatMessage('[Justice Helper] {ffffff}Номера телефонов государственных служб:', message_color)
		sampAddChatMessage('[Justice Helper] {ffffff}111 Баланс | 60 Время | 911 МЮ | 912 МЗ | 913 Такси | 914 Мехи | 8828 Банк | 997 Дома', message_color)
		return false
	end
	if text:find ('{FFFFFF}Время действия маски 20 минут, после исхода времени ее придётся выбросить.') then
		sampAddChatMessage('[Justice Helper] {ffffff}Время действия маски 20 минут, после исхода времени автоматически надену новую', message_color)
		return false
	end
	if text:find ('Время действия маски истекло, вам пришлось ее выбросить.') then
		sampAddChatMessage('[Justice Helper] {ffffff}Время действия маски истекло! Автоматически надеваю новую', message_color)
		sampProcessChatInput("/mask")
		return false
	end
	if text:find('DEBUG') or text:find('Mobile') then
		return false
	end
	if text:find("Вы успешно надели маску") then
		maska = true
		sampAddChatMessage('[Justice Helper] {ffffff}Вы надели маску', message_color)
		return false
	end
	if text:find("Теперь вы в маске") then
		return false
	end
	if text:find("Вы успешно выкинули маску") or text:find("Вы сняли маску") then
		sampAddChatMessage('[Justice Helper] {ffffff}Вы сняли маску!', message_color)
		return false
	end
	if text:find('%[Ошибка%] %{FFFFFF%}Используй: %/wanted %[уровень розыска 1%-6%]') and check_wanted then
		return false
	end
	if text:find('%[Ошибка%] {FFFFFF}Игроков с таким уровнем розыска нету!') and check_wanted then 
		return false 
	end
	if text:find('Вы посадили игрока (.+) в тюрьму на (%d+) минут') and settings.general.auto_doklad_arrest then
		local nick, mins = text:match('Вы посадили игрока (.+) в тюрьму на (%d+) минут')
		sampSendChat('/r ' .. tagReplacements.my_doklad_nick() .. ' на CONTROL. Преступник ' .. nick:gsub('_', ' ') .. ' посажен в КПЗ на ' .. mins .. ' минут!')
	end
	
end
function sampev.onSendChat(text)
	local ignore = {
		[";)"] = true,
		[":D"] = true,
		[":O"] = true,
		[":|"] = true,
		[")"] = true,
		["))"] = true,
		["("] = true,
		["(("] = true,
		["xD"] = true,
		["q"] = true,
		["(+)"] = true,
		["(-)"] = true,
		[":)"] = true,
		[":("] = true,
		["=)"] = true,
		[":p"] = true,
		[";p"] = true,
		["(rofl)"] = true,
		["XD"] = true,
		["(agr)"] = true,
		["O.o"] = true,
		[">.<"] = true,
		[">:("] = true,
		["<3"] = true,
	}
	if ignore[text] then
		return {text}
	end
	if settings.general.rp_chat then
		text = text:sub(1, 1):rupper()..text:sub(2, #text) 
		if not text:find('(.+)%.') and not text:find('(.+)%!') and not text:find('(.+)%?') then
			text = text .. '.'
		end
	end
	if settings.general.accent_enable then
		text = settings.player_info.accent .. ' ' .. text 
	end
	return {text}
end
function sampev.onSendCommand(text)
	if settings.general.rp_chat then
		local chats =  { '/vr', '/fam', '/al', '/s', '/b', '/n', '/r', '/rb', '/f', '/fb', '/j', '/jb', '/m', '/do'} 
		for _, cmd in ipairs(chats) do
			if text:find('^'.. cmd .. ' ') then
				local cmd_text = text:match('^'.. cmd .. ' (.+)')
				if cmd_text ~= nil then
					cmd_text = cmd_text:sub(1, 1):rupper()..cmd_text:sub(2, #cmd_text)
					text = cmd .. ' ' .. cmd_text
					if not text:find('(.+)%.') and not text:find('(.+)%!') and not text:find('(.+)%?') then
						text = text .. '.'
					end
				end
			end
		end
	end
	return {text}
end
function sampev.onShowDialog(dialogid, style, title, button1, button2, text)
	
	if title:find('Основная статистика') and check_stats then -- получение статистики
		if text:find("{FFFFFF}Имя: {B83434}%[(.-)]") then
			settings.player_info.name_surname = TranslateNick(text:match("{FFFFFF}Имя: {B83434}%[(.-)]"))
			input_name_surname = imgui.new.char[256](u8(settings.player_info.name_surname))
			sampAddChatMessage('[Justice Helper] {ffffff}Ваше Имя и Фамилия обнаружены, вы - ' .. settings.player_info.name_surname, message_color)
		end
		if text:find("{FFFFFF}Пол: {B83434}%[(.-)]") then
			settings.player_info.sex = text:match("{FFFFFF}Пол: {B83434}%[(.-)]")
			sampAddChatMessage('[Justice Helper] {ffffff}Ваш пол обнаружен, вы - ' .. settings.player_info.sex, message_color)
		end
		if text:find("{FFFFFF}Организация: {B83434}%[(.-)]") then
			settings.player_info.fraction = text:match("{FFFFFF}Организация: {B83434}%[(.-)]")
			if settings.player_info.fraction == 'Не имеется' then
				sampAddChatMessage('[Justice Helper] {ffffff}Вы не состоите в организации!',message_color)
				settings.player_info.fraction_tag = "Неизвестно"
			else
				sampAddChatMessage('[Justice Helper] {ffffff}Ваша организация обнаружена, это: '..settings.player_info.fraction, message_color)
				if settings.player_info.fraction == 'Полиция ЛС' or settings.player_info.fraction == 'Полиция LS' then
					settings.player_info.fraction_tag = 'ЛСПД'
				elseif settings.player_info.fraction == 'Полиция ЛВ' or settings.player_info.fraction == 'Полиция LV' then
					settings.player_info.fraction_tag = 'ЛВПД'
				elseif settings.player_info.fraction == 'Полиция СФ' or settings.player_info.fraction == 'Полиция SF' then
					settings.player_info.fraction_tag = 'СФПД'
				elseif settings.player_info.fraction == 'Областная полиция' then
					settings.player_info.fraction_tag = 'РКШД'
				elseif settings.player_info.fraction == 'FBI' or settings.player_info.fraction == 'ФБР' then
					settings.player_info.fraction_tag = 'ФБР'
				elseif settings.player_info.fraction:find('Тюрьма Строгого режима') then
					settings.player_info.fraction_tag = 'ТСР'
				elseif settings.player_info.fraction == 'Армия SF' or settings.player_info.fraction == 'Армия СФ' then
					settings.player_info.fraction_tag = 'СФа'
				elseif settings.player_info.fraction == 'Армия ЛС' or settings.player_info.fraction == 'Армия LS' then
					settings.player_info.fraction_tag = 'ЛСа'
				else
					settings.player_info.fraction_tag = 'ПД'
				end
				settings.deportament.dep_tag1 = '[' .. settings.player_info.fraction_tag .. ']'
				input_dep_tag1 = imgui.new.char[32](u8(settings.deportament.dep_tag1))
				input_fraction_tag = imgui.new.char[256](u8(settings.player_info.fraction_tag))
				sampAddChatMessage('[Justice Helper] {ffffff}Вашей организации присвоен тег '..settings.player_info.fraction_tag .. ". Но вы можете изменить его.", message_color)
			end
		end
		if text:find("{FFFFFF}Должность: {B83434}(.+)%((%d+)%)") then
			settings.player_info.fraction_rank, settings.player_info.fraction_rank_number = text:match("{FFFFFF}Должность: {B83434}(.+)%((%d+)%)(.+)Уровень розыска")
			sampAddChatMessage('[Justice Helper] {ffffff}Ваша должность обнаружена, это: '..settings.player_info.fraction_rank.." ("..settings.player_info.fraction_rank_number..")", message_color)
			if tonumber(settings.player_info.fraction_rank_number) >= 9 then
				settings.general.auto_uval = true
				initialize_commands()
			end
		else
			settings.player_info.fraction_rank = "Неизвестно"
			settings.player_info.fraction_rank_number = 0
			sampAddChatMessage('[Justice Helper] {ffffff}Произошла ошибка, не могу получить ваш ранг!',message_color)
		end
		save_settings()
		sampSendDialogResponse(235, 0,0,0)
		check_stats = false

		return false
	end

	if spawncar_bool and title:find('$') and text:find('Спавн транспорта') then -- спавн транспорта
		sampSendDialogResponse(dialogid, 2, 3, 0)
		spawncar_bool = false
		return false 
	end
	
	if vc_vize_bool and text:find('Управление разрешениями на командировку в Vice City') then -- VS Visa [0]
		sampSendDialogResponse(dialogid, 1, 8, 0)
		return false 
	end
	
	if vc_vize_bool and title:find('Выдача разрешений на поездки Vice City') then -- VS Visa [1]
		vc_vize_bool = false
		sampSendChat("/r Сотруднику "..TranslateNick(sampGetPlayerNickname(tonumber(vc_vize_player_id))).." выдана виза Vice City!")
		sampSendDialogResponse(dialogid, 1, 0, tostring(vc_vize_player_id))
		return false 
	end
	
	if vc_vize_bool and title:find('Забрать разрешение на поездки Vice City') then -- VS Visa [2]
		vc_vize_bool = false
		sampSendChat("/r У сотрудника "..TranslateNick(sampGetPlayerNickname(tonumber(vc_vize_player_id))).." была изьята виза Vice City!")
		sampSendDialogResponse(dialogid, 1, 0, tostring(sampGetPlayerNickname(vc_vize_player_id)))
		return false 
	end

	if title:find('Сущности рядом') then -- arz fastmenu
		sampSendDialogResponse(dialogid, 0, 2, 0)
		return false 
	end

	if members_check and title:find('(.+)%(В сети: (%d+)%)') then -- мемберс 
        local count = 0
        local next_page = false
        local next_page_i = 0
		members_fraction = string.match(title, '(.+)%(В сети')
		members_fraction = string.gsub(members_fraction, '{(.+)}', '')
        for line in text:gmatch('[^\r\n]+') do
            count = count + 1
            if not line:find('Ник') and not line:find('страница') then
				local color, nickname, id, rank, rank_number, warns, afk = string.match(line, '{(.+)}(.+)%((%d+)%)\t(.+)%((%d+)%)\t(%d+) %((%d+)')
				if color ~= nil and nickname ~= nil and id ~= nil and rank ~= nil and rank_number ~= nil and warns ~= nil and afk ~= nil then
					local working = false
					if color:find('FF3B3B') then
						working = false
					elseif color:find('FFFFFF') then
						working = true
					end
					table.insert(members_new, { nick = nickname, id = id, rank = rank, rank_number = rank_number, warns = warns, afk = afk, working = working })
				end
            end
            if line:match('Следующая страница') then
                next_page = true
                next_page_i = count - 2
            end
        end
        if next_page then
            sampSendDialogResponse(dialogid, 1, next_page_i, 0)
            next_page = false
            next_pagei = 0
        else
            sampSendDialogResponse(dialogid, 0, 0, 0)
			members = members_new
			members_check = false
			MembersWindow[0] = true
        end
        return false
    end

	if title:find('Выберите ранг для (.+)') and text:find('вакансий') then -- invite
		sampSendDialogResponse(dialogid, 1, 0, 0)
		return false
	end

	if text:find('Ник') and text:find('Уровень розыска') and text:find('Расстояние') and check_wanted then
		local text = string.gsub(text, '%{......}', '')
		text = string.gsub(text, 'Ник%s+Уровень розыска%s+Расстояние\n', '')
		for line in string.gmatch(text, '[^\n]+') do
			local nick, id, lvl, dist = string.match(line, '(%w+_%w+)%((%d+)%)%s+(%d) уровень%s+%[(.+)%]')
			if nick and id and lvl and dist then
				if dist:find('в интерьере') then
					dist = 'В инте'
				end
				table.insert(wanted_new, {nick = nick, id = id, lvl = lvl, dist = dist})
			end
		end
		sampSendDialogResponse(dialogid, 1, 999999, 0)
		return false
	end

	if title:find('Дата и время убийства') then
		local data = text:match('%{FFFFFF%}Дата и время%: %{90EE90%}(.+)\n%{FFFFFF%}Орудие убийства')
		if debug_mode then sampAddChatMessage('[Justice Helper] Автозаполнение данных: ' .. data , message_color) end
		sampSendDialogResponse(dialogid, 1, 0, data)
		return false
	end

	if title:find('Орудие убийства') then
		if text:find("Неизвестно") then
			sampSendDialogResponse(dialogid, 1, 0, "Неизвестно")
		else
			local data = text:match('Орудие убийства%: %{90EE90%}(.+)\n\n')
			if debug_mode then sampAddChatMessage('[Justice Helper] {ffffff}Автозаполнение данных: ' .. data , message_color) end
			sampSendDialogResponse(dialogid, 1, 0, data)
		end
		return false
	end
	
end
-- function OnShowCEFDialog(dialogid) end
function onReceivePacket(id, bs)  
	if isMonetLoader() then
		if id == 220 then
			local id = raknetBitStreamReadInt8(bs)
			local _1 = raknetBitStreamReadInt8(bs)
			local _2 = raknetBitStreamReadInt16(bs)
			local _3 = raknetBitStreamReadInt32(bs)
			-- автоматический клик для МОБАЙЛ "Крушение самолета" и "Авария на шосе" (взято из кода XRLM)
			if _3 > 2 and _3 <= raknetBitStreamGetNumberOfUnreadBits(bs) then
				local _4 = raknetBitStreamReadString(bs, _3)
				if _4:find('{"progress":%d+,"text":"Для взаимодействия, нажимайте на кнопку посередине"}') and settings.general.auto_clicker_situation then
					clicked = true
				end
			end
		end
	else
		if id == 220 then
			raknetBitStreamIgnoreBits(bs, 8)
			if raknetBitStreamReadInt8(bs) == 17 then
				raknetBitStreamIgnoreBits(bs, 32)
				local cmd2 = raknetBitStreamReadString(bs, raknetBitStreamReadInt32(bs))
				--sampAddChatMessage(cmd2,-1)
				-- автоматический клик для ПК "Крушение самолета" и "Авария на шосе" (взято из кода Chapo)
				local view = string.match(cmd2, "^window.executeEvent%('event%.setActiveView', [`']%[[\"%s]?(.-)[\"%s]?%][`']%);$")
				if view ~= nil and settings.general.auto_clicker_situation then
					clicked = (view == "Clicker")
				end

				if cmd2:find('Основная статистика') and check_stats then -- /jme
					sampAddChatMessage('[Justice Helper] {ffffff}Ошибка, не могу получить данные из нового CEF диалога!', message_color)
					sampAddChatMessage('[Justice Helper] {ffffff}Включите старый (класичесский) вид диалогов в /settings - Кастомизация интерфейса', message_color)
					run_code("window.executeEvent('cef.modals.closeModal', `[\"dialog\"]`);")
				end
				
			end
		end
	end
end
function onSendPacket(id, bs)
	if id == 220 and isMonetLoader() then
		-- автоматический клик для МОБАЙЛ "Крушение самолета" и "Авария на шосе" (взято из кода XRLM)
		local id = raknetBitStreamReadInt8(bs)
		local _1 = raknetBitStreamReadInt8(bs)
		local _2 = raknetBitStreamReadInt8(bs)
		if _1 == 66 and (_2 == 25 or _2 == 8) and settings.general.auto_clicker_situation then
			clicked = false
		end
	end
end

imgui.OnInitialize(function()
	imgui.GetIO().IniFilename = ni
	fa.Init(14 * MONET_DPI_SCALE)
	if settings.general.moonmonet_theme_enable and monet_no_errors then
		apply_moonmonet_theme()
	else 
		apply_dark_theme()
	end
end)

imgui.OnFrame(
    function() return MainWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, 425	* MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.BUILDING_SHIELD .. " Justice Helper##main", MainWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize )
		if imgui.BeginTabBar('пон') then	
			if imgui.BeginTabItem(fa.HOUSE..u8' Главное меню') then
				if imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 171 * MONET_DPI_SCALE), true) then
					imgui.CenterText(fa.USER_NURSE .. u8' Информация про сотрудника')
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Имя и Фамилия:")
					imgui.SetColumnWidth(-1, 230 * MONET_DPI_SCALE)
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.name_surname))
					imgui.SetColumnWidth(-1, 250 * MONET_DPI_SCALE)
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'Изменить##name_surname') then
						settings.player_info.name_surname = TranslateNick(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
						input_name_surname = imgui.new.char[256](u8(settings.player_info.name_surname))
						save_settings()
						imgui.OpenPopup(fa.USER_NURSE .. u8' Имя и Фамилия##name_surname')
					end
					if imgui.BeginPopupModal(fa.USER_NURSE .. u8' Имя и Фамилия##name_surname', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  ) then
						imgui.PushItemWidth(405 * MONET_DPI_SCALE)
						imgui.InputText(u8'##name_surname', input_name_surname, 256) 
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							settings.player_info.name_surname = u8:decode(ffi.string(input_name_surname))
							save_settings()
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Пол:")
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.sex))
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'Изменить##sex') then
						if settings.player_info.sex == 'Неизвестно' then
							settings.player_info.sex = 'Женщина'
							save_settings()
						elseif settings.player_info.sex == 'Мужчина' then
							settings.player_info.sex = 'Женщина'
							save_settings()
						elseif settings.player_info.sex == 'Женщина' then
							settings.player_info.sex = 'Мужчина'
							save_settings()
						end
					end
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Акцент:")
					imgui.NextColumn()
					if checkbox_accent_enable[0] then
						imgui.CenterColumnText(u8(settings.player_info.accent))
					else 
						imgui.CenterColumnText(u8'Отключено')
					end
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'Изменить##accent') then
						imgui.OpenPopup(fa.USER_NURSE .. u8' Акцент персонажа##accent')
					end
					if imgui.BeginPopupModal(fa.USER_NURSE .. u8' Акцент персонажа##accent', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  ) then
						if imgui.Checkbox('##checkbox_accent_enable', checkbox_accent_enable) then
							settings.general.accent_enable = checkbox_accent_enable[0]
							save_settings()
						end
						imgui.SameLine()
						imgui.PushItemWidth(375 * MONET_DPI_SCALE)
						imgui.InputText(u8'##accent_input', input_accent, 256) 
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then 
							settings.player_info.accent = u8:decode(ffi.string(input_accent))
							save_settings()
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Организация:")
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.fraction))
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'Обновить##fraction') then
						check_stats = true
						sampSendChat('/stats')
					end
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Тэг организации:")
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.fraction_tag))
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'Изменить##fraction_tag') then
						imgui.OpenPopup(fa.BUILDING_SHIELD .. u8' Тэг организации##fraction_tag')
					end
					if imgui.BeginPopupModal(fa.BUILDING_SHIELD .. u8' Тэг организации##fraction_tag', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  ) then
						imgui.PushItemWidth(405 * MONET_DPI_SCALE)
						imgui.InputText(u8'##input_fraction_tag', input_fraction_tag, 256)
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							settings.player_info.fraction_tag = u8:decode(ffi.string(input_fraction_tag))
							save_settings()
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Должность в организации:")
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.fraction_rank) .. " (" .. settings.player_info.fraction_rank_number .. ")")
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8"Обновить##rank") then
						check_stats = true
						sampSendChat('/stats')
					end
					imgui.Columns(1)
				
				imgui.EndChild()
				end
				if imgui.BeginChild('##2', imgui.ImVec2(589 * MONET_DPI_SCALE, 53 * MONET_DPI_SCALE), true) then
					imgui.CenterText(fa.ROBOT .. u8' Асистент')
					imgui.Separator()
					imgui.Columns(2)
					imgui.CenterColumnText(u8("Ваш незаменимый помощник для автоматизации некоторых действий"))
					imgui.SetColumnWidth(-1, 480 * MONET_DPI_SCALE)
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'Управление') then
						--sampAddChatMessage('[Justice Helper] {ffffff}Асистент ещё в разработке!', message_color)
						imgui.OpenPopup(fa.ROBOT .. u8' Асистент для автоматизации некоторых ваших действий')
					end
					if imgui.BeginPopupModal(fa.ROBOT .. u8' Асистент для автоматизации некоторых ваших действий', _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize ) then
						imgui.BeginChild('##ai', imgui.ImVec2(589 * MONET_DPI_SCALE, 360 * MONET_DPI_SCALE), true)
						if imgui.Checkbox(u8(' Надевать новую маску (/mask) когда время действия прошлой маски закончилось'), checkbox_automask) then
							settings.general.auto_mask = checkbox_automask[0]
							save_settings()
						end
						if imgui.Checkbox(u8(' Когда кто-то наносит вам урон любым способом делать доклад в рацию про CODE 0'), checkbox_autodoklad_damage) then
							settings.general.auto_doklad_damage = checkbox_autodoklad_damage[0]
							save_settings()
						end
						if imgui.Checkbox(u8(' При патруле (/patrool) каждые 10 мин делать доклад в рацию'), checkbox_patrool_autodoklad) then
							settings.general.auto_doklad_patrool = checkbox_patrool_autodoklad[0]
							save_settings()
						end
						if imgui.Checkbox(u8(' При вкл/выкл мигалок изменить ситуационный код на CODE 3 / CODE 4'), checkbox_change_code_siren) then
							settings.general.auto_change_code_siren = checkbox_change_code_siren[0]
							save_settings()
						end
						if imgui.Checkbox(u8(' После ареста (/arrest) делать доклад в рацию про заверешнный арест'), checkbox_autodoklad_arrest) then
							settings.general.auto_doklad_arrest = checkbox_autodoklad_arrest[0]
							save_settings()
						end
						if imgui.Checkbox(u8(' Напоминать в чате про мероприятие "Порт" за 5 минут до начала'), checkbox_notify_port) then
							settings.general.auto_notify_port = checkbox_notify_port[0]
							save_settings()
						end
						if imgui.Checkbox(u8(' Напоминать в чате про PAYDAY за 5 минут до него'), checkbox_notify_payday) then
							settings.general.auto_notify_payday = checkbox_notify_payday[0]
							save_settings()
						end
						if imgui.Checkbox(u8(' Обновлять список сотрудников в меню /mb каждые 3 секунды'), checkbox_update_members) then
							settings.general.auto_update_members = checkbox_update_members[0]
							save_settings()
						end
						if imgui.Checkbox(u8(' Обновлять список преступников в меню /wanteds каждые 3 секунды'), checkbox_update_wanteds) then
							settings.general.auto_update_wanteds = checkbox_update_wanteds[0]
							save_settings()
						end
						if imgui.Checkbox(u8(' Автокликер в Случайных Ситуациях (сбор камней)'), checkbox_auto_clicker) then
							settings.general.auto_clicker_situation = checkbox_auto_clicker[0]
							save_settings()
						end
						if imgui.Checkbox(u8(' '),checkboxone) then

						end
						if imgui.Checkbox(u8(' '),checkboxone) then

						end
						imgui.EndChild()
						if imgui.Button(fa.CIRCLE_XMARK .. u8" Закрыть", imgui.ImVec2(imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndPopup()
					end
					imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
					imgui.Columns(1)
				imgui.EndChild()
				end
				if imgui.BeginChild('##3', imgui.ImVec2(589 * MONET_DPI_SCALE, 127 * MONET_DPI_SCALE), true) then
					imgui.CenterText(fa.SITEMAP .. u8' Дополнительные функции хелпера')
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Информационное меню")
					imgui.SameLine(nil, 5) imgui.TextDisabled("[?]")
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"Отображение на экране менюшки с информацией")
					end
					imgui.SetColumnWidth(-1, 230 * MONET_DPI_SCALE)
					imgui.NextColumn()
					if settings.general.use_info_menu then
						imgui.CenterColumnText(u8'Включено')
					else
						imgui.CenterColumnText(u8'Отключено')
					end
					imgui.SetColumnWidth(-1, 250 * MONET_DPI_SCALE)
					imgui.NextColumn()
					if settings.general.use_info_menu then
						if imgui.CenterColumnSmallButton(u8'Отключить##info_menu') then
							settings.general.use_info_menu = false
							InformationWindow[0] = false
							Information1Window[0] = false
							save_settings()
						end
						else
						if imgui.CenterColumnSmallButton(u8'Включить##info_menu') then
							settings.general.use_info_menu = true
							InformationWindow[0] = true
							Information1Window[0] = true
							save_settings()
						end
					end
					imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Режим RP отыгровки оружия")
					imgui.SameLine(nil, 5) imgui.TextDisabled("[?]")
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"При использовании/скролле оружия в чате будут RP отыгровки.")
					end
					imgui.NextColumn()
					if settings.general.rp_gun then
						imgui.CenterColumnText(u8'Включено')
					else
						imgui.CenterColumnText(u8'Отключено')
					end
					imgui.NextColumn()
					if settings.general.rp_gun then
						if imgui.CenterColumnSmallButton(u8'Отключить##rp_gun') then
							settings.general.rp_gun = false
							save_settings()
						end
					else
						if imgui.CenterColumnSmallButton(u8'Включить##rp_gun') then
							settings.general.rp_gun = true
							save_settings()
						end
					end
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Режим RP общения в чатах")
					imgui.SameLine(nil, 5) imgui.TextDisabled("[?]")
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"Все ваши сообщения будут с заглавной буквы и с точкой в конце.\nРаботает в обычном чате и некоторых часто используемых командах:\n/r /rb /j /jb /m /s /b /n /do /vr /fam /al")
					end
					imgui.NextColumn()
					if settings.general.rp_chat then
						imgui.CenterColumnText(u8'Включено')
					else
						imgui.CenterColumnText(u8'Отключено')
					end
					imgui.NextColumn()
					if settings.general.rp_chat then
						if imgui.CenterColumnSmallButton(u8'Отключить##rp_chat') then
							settings.general.rp_chat = false
							save_settings()
						end
						else
						if imgui.CenterColumnSmallButton(u8'Включить##rp_chat') then
							settings.general.rp_chat = true
							save_settings()
						end
					end
					imgui.Columns(1)
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"Автоматический увал")
					imgui.SameLine(nil, 5) imgui.TextDisabled("[?]")
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"Функция только для лидера или его заместителей!\nПозволяет автоматически увольнять тех кто просит ПСЖ\nС подверждением от игрока, путём отправки сообщения в /rb")
					end
					imgui.NextColumn()
					if settings.general.auto_uval then
						imgui.CenterColumnText(u8'Включено')
					else
						imgui.CenterColumnText(u8'Отключено')
					end
					imgui.NextColumn()
					if settings.general.auto_uval then
						if imgui.CenterColumnSmallButton(u8'Отключить##auto_uval') then
							settings.general.auto_uval = false
							save_settings()
						end
					else
						if imgui.CenterColumnSmallButton(u8'Включить##auto_uval') then
							if tonumber(settings.player_info.fraction_rank_number) == 9 or tonumber(settings.player_info.fraction_rank_number) == 10 then 
								settings.general.auto_uval = true
								save_settings()
							else
								settings.general.auto_uval = false
								sampAddChatMessage('[Justice Helper] {ffffff}Эта Функция доступна только лидеру и заместителям!',message_color)
							end
						end
					end
					imgui.Columns(1)
					-- imgui.Separator()
				imgui.EndChild()
				end
				imgui.EndTabItem()
			end
			if imgui.BeginTabItem(fa.RECTANGLE_LIST..u8' Команды и отыгровки') then 
				if imgui.BeginTabBar('Tabs2') then
					if imgui.BeginTabItem(fa.BARS..u8' Общие команды для всех рангов ') then 
						if imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 303 * MONET_DPI_SCALE), true) then
							imgui.Columns(3)
							imgui.CenterColumnText(u8"Команда")
							imgui.SetColumnWidth(-1, 170 * MONET_DPI_SCALE)
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Описание")
							imgui.SetColumnWidth(-1, 300 * MONET_DPI_SCALE)
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Действие")
							imgui.SetColumnWidth(-1, 150 * MONET_DPI_SCALE)
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/jh")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Открыть главное меню хелпера")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/jm")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Открыть быстрое меню взаимодействия")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/wanteds")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Открыть меню всего /wanted")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/mb")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Открыть меню всего /members")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/dep")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Открыть меню рации депортамента")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/patrool")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Открыть меню патрулирования")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/pnv")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Надеть/снять очки ночного видения")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/irv")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Надеть/снять инфакрасные очки")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/mask")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Надеть/снять балаклаву")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"Недоступно")
							imgui.Columns(1)
							imgui.Separator()
							for index, command in ipairs(commands.commands) do
								imgui.Columns(3)
								if command.enable then
									imgui.CenterColumnText('/' .. u8(command.cmd))
									imgui.NextColumn()
									imgui.CenterColumnText(u8(command.description))
									imgui.NextColumn()
								else
									imgui.CenterColumnTextDisabled('/' .. u8(command.cmd))
									imgui.NextColumn()
									imgui.CenterColumnTextDisabled(u8(command.description))
									imgui.NextColumn()
								end
								imgui.Text(' ')
								imgui.SameLine()
								if command.enable then
									if imgui.SmallButton(fa.TOGGLE_ON .. '##'..command.cmd) then
										command.enable = not command.enable
										save_commands()
										sampUnregisterChatCommand(command.cmd)
									end
									if imgui.IsItemHovered() then
										imgui.SetTooltip(u8"Отключение команды /"..command.cmd)
									end
								else
									if imgui.SmallButton(fa.TOGGLE_OFF .. '##'..command.cmd) then
										command.enable = not command.enable
										save_commands()
										register_command(command.cmd, command.arg, command.text, tonumber(command.waiting))
									end
									if imgui.IsItemHovered() then
										imgui.SetTooltip(u8"Включение команды /"..command.cmd)
									end
								end
								imgui.SameLine()
								if imgui.SmallButton(fa.PEN_TO_SQUARE .. '##'..command.cmd) then
									change_description = command.description
									input_description = imgui.new.char[256](u8(change_description))
									change_arg = command.arg
									if command.arg == '' then
										ComboTags[0] = 0
									elseif command.arg == '{arg}' then	
										ComboTags[0] = 1
									elseif command.arg == '{arg_id}' then
										ComboTags[0] = 2
									elseif command.arg == '{arg_id} {arg2}' then
										ComboTags[0] = 3
									elseif command.arg == '{arg_id} {arg2} {arg3}' then
										ComboTags[0] = 4
									end
									change_cmd = command.cmd
									input_cmd = imgui.new.char[256](u8(command.cmd))
									change_text = command.text:gsub('&', '\n')		
									input_text = imgui.new.char[8192](u8(change_text))
									change_waiting = command.waiting
									waiting_slider = imgui.new.float(tonumber(command.waiting))	
									BinderWindow[0] = true
								end
								if imgui.IsItemHovered() then
									imgui.SetTooltip(u8"Изменение команды /"..command.cmd)
								end
								imgui.SameLine()
								if imgui.SmallButton(fa.TRASH_CAN .. '##'..command.cmd) then
									imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##' .. command.cmd)
								end
								if imgui.IsItemHovered() then
									imgui.SetTooltip(u8"Удаление команды /"..command.cmd)
								end
								if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##' .. command.cmd, _, imgui.WindowFlags.NoResize ) then
									imgui.CenterText(u8'Вы действительно хотите удалить команду /' .. u8(command.cmd) .. '?')
									imgui.Separator()
									if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
										imgui.CloseCurrentPopup()
									end
									imgui.SameLine()
									if imgui.Button(fa.TRASH_CAN .. u8' Да, удалить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
										sampUnregisterChatCommand(command.cmd)
										table.remove(commands.commands, index)
										save_commands()
										imgui.CloseCurrentPopup()
									end
									imgui.End()
								end
								imgui.Columns(1)
								imgui.Separator()
							end
							imgui.EndChild()
						end
						if imgui.Button(fa.CIRCLE_PLUS .. u8' Создать новую команду##new_cmd',imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then
							local new_cmd = {cmd = '', description = '', text = '', arg = '', enable = true , waiting = '1.200' }
							binder_create_command_9_10 = false
							table.insert(commands.commands, new_cmd)
							change_description = new_cmd.description
							input_description = imgui.new.char[256](u8(change_description))
							change_arg = new_cmd.arg
							ComboTags[0] = 0
							change_cmd = new_cmd.cmd
							input_cmd = imgui.new.char[256](u8(new_cmd.cmd))
							change_text = new_cmd.text:gsub('&', '\n')
							input_text = imgui.new.char[8192](u8(change_text))
							change_waiting = 1.200
							waiting_slider = imgui.new.float(1.200)	
							BinderWindow[0] = true
						end
						imgui.EndTabItem()
					end
					if imgui.BeginTabItem(fa.BARS..u8' Команды для 9-10 рангов') then 
						if tonumber(settings.player_info.fraction_rank_number) == 9 or tonumber(settings.player_info.fraction_rank_number) == 10 then
							if imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 303 * MONET_DPI_SCALE), true) then
								imgui.Columns(3)
								imgui.CenterColumnText(u8"Команда")
								imgui.SetColumnWidth(-1, 170 * MONET_DPI_SCALE)
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Описание")
								imgui.SetColumnWidth(-1, 300 * MONET_DPI_SCALE)
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Действие")
								imgui.SetColumnWidth(-1, 150 * MONET_DPI_SCALE)
								imgui.Columns(1)
								imgui.Separator()
								imgui.Columns(3)
								imgui.CenterColumnText(u8"/jlm")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Открыть быстрое меню управления")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Недоступно")
								imgui.Columns(1)
								imgui.Separator()
								imgui.Columns(3)
								imgui.CenterColumnText(u8"/spcar")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Заспавнить транспорта организации")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Недоступно")
								imgui.Columns(1)
								imgui.Separator()		
								imgui.Columns(3)
								imgui.CenterColumnText(u8"/sob")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Открыть меню собеседования")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"Недоступно")
								imgui.Columns(1)
								imgui.Separator()		
								for index, command in ipairs(commands.commands_manage) do
									imgui.Columns(3)
									if command.enable then
										imgui.CenterColumnText('/' .. u8(command.cmd))
										imgui.NextColumn()
										imgui.CenterColumnText(u8(command.description))
										imgui.NextColumn()
									else
										imgui.CenterColumnTextDisabled('/' .. u8(command.cmd))
										imgui.NextColumn()
										imgui.CenterColumnTextDisabled(u8(command.description))
										imgui.NextColumn()
									end
									imgui.Text('  ')
									imgui.SameLine()
									if command.enable then
										if imgui.SmallButton(fa.TOGGLE_ON .. '##'..command.cmd) then
											command.enable = not command.enable
											save_commands()
											sampUnregisterChatCommand(command.cmd)
										end
										if imgui.IsItemHovered() then
											imgui.SetTooltip(u8"Отключение команды /"..command.cmd)
										end
									else
										if imgui.SmallButton(fa.TOGGLE_OFF .. '##'..command.cmd) then
											command.enable = not command.enable
											save_commands()
											register_command(command.cmd, command.arg, command.text, tonumber(command.waiting))
										end
										if imgui.IsItemHovered() then
											imgui.SetTooltip(u8"Включение команды /"..command.cmd)
										end
									end
									imgui.SameLine()
									if imgui.SmallButton(fa.PEN_TO_SQUARE .. '##'..command.cmd) then
										change_description = command.description
										input_description = imgui.new.char[256](u8(change_description))
										change_arg = command.arg
										if command.arg == '' then
											ComboTags[0] = 0
										elseif command.arg == '{arg}' then	
											ComboTags[0] = 1
										elseif command.arg == '{arg_id}' then
											ComboTags[0] = 2
										elseif command.arg == '{arg_id} {arg2}' then
											ComboTags[0] = 3
										elseif command.arg == '{arg_id} {arg2} {arg3}' then
											ComboTags[0] = 4
										end
										change_cmd = command.cmd
										input_cmd = imgui.new.char[256](u8(command.cmd))
										change_text = command.text:gsub('&', '\n')
										input_text = imgui.new.char[8192](u8(change_text))
										binder_create_command_9_10 = true
										change_waiting = command.waiting
										waiting_slider = imgui.new.float( tonumber(command.waiting) )	
										BinderWindow[0] = true
									end
									if imgui.IsItemHovered() then
										imgui.SetTooltip(u8"Изменение команды /"..command.cmd)
									end
									imgui.SameLine()
									if imgui.SmallButton(fa.TRASH_CAN .. '##'..command.cmd) then
										imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##9-10' .. command.cmd)
									end
									if imgui.IsItemHovered() then	
										imgui.SetTooltip(u8"Удаление команды /"..command.cmd)
									end
									if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##9-10' .. command.cmd, _, imgui.WindowFlags.NoResize ) then
										imgui.CenterText(u8'Вы действительно хотите удалить команду /' .. u8(command.cmd) .. '?')
										imgui.Separator()
										if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
											imgui.CloseCurrentPopup()
										end
										imgui.SameLine()
										if imgui.Button(fa.TRASH_CAN .. u8' Да, удалить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
											sampUnregisterChatCommand(command.cmd)
											table.remove(commands.commands_manage, index)
											save_commands()
											imgui.CloseCurrentPopup()
										end
										imgui.End()
									end
									imgui.Columns(1)
									imgui.Separator()
								end
								imgui.EndChild()
							end
							if imgui.Button(fa.CIRCLE_PLUS .. u8' Создать новую команду##new_cmd_9-10', imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then
								binder_create_command_9_10 = true
								local new_cmd = {cmd = '', description = '', text = '', arg = '', enable = true, waiting = '1.200'}
								table.insert(commands.commands_manage, new_cmd)
								change_description = new_cmd.description
								input_description = imgui.new.char[256](u8(change_description))
								change_arg = new_cmd.arg
								ComboTags[0] = 0
								change_cmd = new_cmd.cmd
								input_cmd = imgui.new.char[256](u8(new_cmd.cmd))
								change_text = new_cmd.text:gsub('&', '\n')
								input_text = imgui.new.char[8192](u8(change_text))
								change_waiting = 1.200
								waiting_slider = imgui.new.float(1.200)	
								BinderWindow[0] = true
							end
						else
							imgui.CenterText(fa.TRIANGLE_EXCLAMATION)
							imgui.Separator()
							imgui.CenterText(u8"У вас нет доступа к данным командам!")
							imgui.CenterText(u8"Необходимо иметь 9 или 10 ранг, у вас же "..settings.player_info.fraction_rank_number..u8" ранг!")
							imgui.Separator()
						end
						imgui.EndTabItem() 
					end
					if imgui.BeginTabItem(fa.BARS..u8' Дополнительные функции') then 
						if imgui.BeginChild('##99', imgui.ImVec2(589 * MONET_DPI_SCALE, 333 * MONET_DPI_SCALE), true) then
							if isMonetLoader() then
								imgui.CenterText(u8'Способ открытия быстрого меню взаимодействия с игроком:')
								if imgui.RadioButtonIntPtr(u8" Только используя команду /jm [ID игрока]", fastmenu_type, 0) then
									fastmenu_type[0] = 0
									settings.general.mobile_fastmenu_button = false
									save_settings()
									FastMenuButton[0] = false
								end
								if imgui.RadioButtonIntPtr(u8' Используя команду /jm [ID игрока] или кнопку "Взаимодействие" в левом углу экрана', fastmenu_type, 1) then
									fastmenu_type[0] = 1
									settings.general.mobile_fastmenu_button = true
									save_settings()
								end
								imgui.Separator()
								imgui.CenterText(u8'Способ приостановки отыгровки команды:')
								if imgui.RadioButtonIntPtr(u8" Только используя команду /stop", stop_type, 0) then
									stop_type[0] = 0
									settings.general.mobile_stop_button = false
									CommandStopWindow[0] = true
									save_settings()
								end
								if imgui.RadioButtonIntPtr(u8' Используя команду /stop или кнопку "Остановить" внизу экрана', stop_type, 1) then
									stop_type[0] = 1
									settings.general.mobile_stop_button = true
									save_settings()
								end
								imgui.Separator()
							else
								imgui.CenterText(fa.KEYBOARD .. u8' Hotkeys')
								if hotkey_no_errors then
									imgui.SameLine()
									if settings.general.use_binds then
										if imgui.SmallButton(fa.TOGGLE_ON .. '##enable_binds') then
											settings.general.use_binds = not settings.general.use_binds
											save_settings()
										end
										if imgui.IsItemHovered() then
											imgui.SetTooltip(u8"Отключить систему биндов")
										end
										if imgui.CenterButton(fa.KEYBOARD .. u8' Настройка клавиш') then
											imgui.OpenPopup(fa.KEYBOARD .. u8' Настройка клавиш')
										end
									else
										if imgui.SmallButton(fa.TOGGLE_OFF .. '##enable_binds') then
											settings.general.use_binds = not settings.general.use_binds
											save_settings()
										end
										if imgui.IsItemHovered() then
											imgui.SetTooltip(u8"Включить систему биндов")
										end
										imgui.CenterButton(u8'Система Хоткеев (биндов) отключена!')
									end
									
								else
									imgui.SameLine()
									imgui.SmallButton(fa.TOGGLE_OFF .. '##enable_binds')
									imgui.CenterText(fa.TRIANGLE_EXCLAMATION .. u8' Ошибка: отсуствуют файлы библиотеки!')
								end
								imgui.Separator()

								if imgui.BeginPopupModal(fa.KEYBOARD .. u8' Настройка клавиш', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  ) then
									imgui.SetWindowSizeVec2(imgui.ImVec2(600 * MONET_DPI_SCALE, 425	* MONET_DPI_SCALE))
									if settings.general.use_binds and hotkey_no_errors then
										imgui.Separator()
										imgui.CenterText(u8'Открытие главного меню хелпера (аналог /jh):')
										local width = imgui.GetWindowWidth()
										local calc = imgui.CalcTextSize(getNameKeysFrom(settings.general.bind_mainmenu))
										imgui.SetCursorPosX( width / 2 - calc.x / 2 )
										if MainMenuHotKey:ShowHotKey() then
											settings.general.bind_mainmenu = encodeJson(MainMenuHotKey:GetHotKey())
											save_settings()
										end
										imgui.Separator()
										imgui.CenterText(u8'Открытие быстрого меню взаимодействия с игроком (аналог /jm):')
										imgui.CenterText(u8'Навестись на игрока через ПКМ и нажать')
										local width = imgui.GetWindowWidth()
										local calc = imgui.CalcTextSize(getNameKeysFrom(settings.general.bind_fastmenu))
										imgui.SetCursorPosX(width / 2 - calc.x / 2)
										if FastMenuHotKey:ShowHotKey() then
											settings.general.bind_fastmenu = encodeJson(FastMenuHotKey:GetHotKey())
											save_settings()
										end
										imgui.Separator()
										imgui.CenterText(u8'Открытие быстрого меню управления игроком (аналог /jlm):')
										imgui.CenterText(u8'Навестись на игрока через ПКМ и нажать')
										local width = imgui.GetWindowWidth()
										local calc = imgui.CalcTextSize(getNameKeysFrom(settings.general.bind_leader_fastmenu))
										imgui.SetCursorPosX(width / 2 - calc.x / 2)
										if LeaderFastMenuHotKey:ShowHotKey() then
											settings.general.bind_leader_fastmenu = encodeJson(LeaderFastMenuHotKey:GetHotKey())
											save_settings()
										end
										
										imgui.Separator()
										imgui.CenterText(u8'Приостановить отыгровку команды (аналог /stop):')
										local width = imgui.GetWindowWidth()
										local calc = imgui.CalcTextSize(getNameKeysFrom(settings.general.bind_command_stop))
										imgui.SetCursorPosX(width / 2 - calc.x / 2)
										if CommandStopHotKey:ShowHotKey() then
											settings.general.bind_command_stop = encodeJson(CommandStopHotKey:GetHotKey())
											save_settings()
										end
										imgui.Separator()
										if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
											imgui.CloseCurrentPopup()
										end
										imgui.Separator()
									end
									imgui.End()
								end

							end
						imgui.EndChild()
					end
					imgui.EndTabItem() 
				end
				imgui.EndTabBar() 
				end
				imgui.EndTabItem()
			end
			if imgui.BeginTabItem(fa.STAR .. u8' Розыск и штрафы') then 
				if imgui.BeginChild('##smartuk', imgui.ImVec2(292 * MONET_DPI_SCALE, 340 * MONET_DPI_SCALE), true) then
					imgui.CenterText(fa.STAR .. u8' Система умного розыска')
					imgui.Separator()
					imgui.SetCursorPosY(100 * MONET_DPI_SCALE)
					imgui.SetCursorPosX(105 * MONET_DPI_SCALE)
					if imgui.Button(fa.DOWNLOAD .. u8' Загрузить ##smartuk') then
						if getARZServerNumber() ~= 0 then
							download_smartuk = true
							downloadFileFromUrlToPath('https://raw.githubusercontent.com/MTGMODS/justice-helper/main/SmartUK/' .. getARZServerNumber() .. '/SmartUK.json', path_uk)
							imgui.OpenPopup(fa.CIRCLE_INFO .. u8' Justice Helper - Оповещение##donwloadsmartuk')
						else
							imgui.OpenPopup(fa.CIRCLE_INFO .. u8' Justice Helper - Оповещение##nocloudsmartuk')
						end
					end
					if imgui.BeginPopupModal(fa.CIRCLE_INFO .. u8' Justice Helper - Оповещение##nocloudsmartuk', _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize) then
						imgui.CenterText(u8'В базе данных ещё нету умного розыска для вашего сервера!')
						imgui.Separator()
						imgui.CenterText(u8'Вы можете вручную заполнить его по кнопке "Отредактировать"')
						imgui.CenterText(u8'Затем вы сможете поделиться им на нашем Discord и он будет загружен в базу данных')
						imgui.CenterText(u8'Вам надо будет скинуть файл SmartUK.json , который находиться по пути:')
						imgui.CenterText(u8(path_uk))
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Хорошо', imgui.ImVec2(550 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndPopup()
					end
					if imgui.BeginPopupModal(fa.CIRCLE_INFO .. u8' Justice Helper - Оповещение##donwloadsmartuk', _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize) then
						if download_smartuk then
							imgui.CenterText(u8'Если вы видите это окно значит идёт скачивание умного розыска для ' .. getARZServerNumber() .. u8' сервера!')
							imgui.CenterText(u8'После заверешения загрузки это окно пропадёт и вы увидите сообщение в чате!')
							imgui.Separator()
							imgui.CenterText(u8'Если же ничего не происходит, значит произошла ошибка скачивания SmartUK.json')
							imgui.CenterText(u8'Возможно в базе данных нету файла именно для вашего сервера!')
							imgui.Separator()
							imgui.CenterText(u8'В этом случае вы можете вручную заполнить его по кнопке "Отредактировать"')
							imgui.CenterText(u8'Затем вы сможете поделиться им на нашем Discord и он будет загружен в базу данных')
							imgui.CenterText(u8'Вам надо будет скинуть файл SmartUK.json , который находиться по пути:')
							imgui.CenterText(u8(path_uk))
							imgui.Separator()
						else
							imgui.CloseCurrentPopup()
						end
						if imgui.Button(fa.CIRCLE_INFO .. u8' Хорошо', imgui.ImVec2(550 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndPopup()
					end
					imgui.SetCursorPosX(80 * MONET_DPI_SCALE)
					imgui.SetCursorPosY(170 * MONET_DPI_SCALE)
					if imgui.Button(fa.PEN_TO_SQUARE .. u8' Отредактировать ##smartuk') then
						imgui.OpenPopup(fa.STAR .. u8' Система умного розыска##smartuk')
					end
					imgui.SetCursorPosY(250 * MONET_DPI_SCALE)
					imgui.CenterText(u8('Использование: /sum [ID игрока]'))
					if imgui.BeginPopupModal(fa.STAR .. u8' Система умного розыска##smartuk', _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize ) then
						imgui.BeginChild('##smartukedit', imgui.ImVec2(589 * MONET_DPI_SCALE, 360 * MONET_DPI_SCALE), true)
						for chapter_index, chapter in ipairs(smart_uk) do
							imgui.Columns(2)
							imgui.BulletText(u8(chapter.name))
							imgui.SetColumnWidth(-1, 515 * MONET_DPI_SCALE)
							imgui.NextColumn()
							if imgui.Button(fa.PEN_TO_SQUARE .. '##' .. chapter_index) then
								imgui.OpenPopup(u8(chapter.name).. '##' .. chapter_index)
							end
							imgui.SameLine()
							if imgui.Button(fa.TRASH_CAN .. '##' .. chapter_index) then
								imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Justice_Helper - Предупреждение ##' .. chapter_index)
							end
							if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Justice_Helper - Предупреждение ##' .. chapter_index, _, imgui.WindowFlags.NoResize ) then
								imgui.CenterText(u8'Вы действительно хотите удалить пункт?')
								imgui.CenterText(u8(chapter.name))
								imgui.Separator()
								if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
									imgui.CloseCurrentPopup()
								end
								imgui.SameLine()
								if imgui.Button(fa.TRASH_CAN .. u8' Да, удалить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
									table.remove(smart_uk, chapter_index)
									save_smart_uk()
									imgui.CloseCurrentPopup()
								end
								imgui.End()
							end
							imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
							imgui.Columns(1)
							if imgui.BeginPopupModal(u8(chapter.name) .. '##' .. chapter_index, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
								if imgui.BeginChild('##smartukedititem', imgui.ImVec2(589 * MONET_DPI_SCALE, 390 * MONET_DPI_SCALE), true) then
									if chapter.item then
										for index, item in ipairs(chapter.item) do
											imgui.Columns(2)
											imgui.BulletText(u8(item.text))
											imgui.SetColumnWidth(-1, 515 * MONET_DPI_SCALE)
											imgui.NextColumn()
											if imgui.Button(fa.PEN_TO_SQUARE .. '##' .. chapter_index .. '##' .. index) then
												input_smartuk_text = imgui.new.char[256](u8(item.text))
												input_smartuk_lvl = imgui.new.char[256](u8(item.lvl))
												input_smartuk_reason = imgui.new.char[256](u8(item.reason))
												imgui.OpenPopup(fa.PEN_TO_SQUARE .. u8(" Редактирование подпункта##") .. chapter.name .. index .. chapter_index)
											end
											if imgui.BeginPopupModal(fa.PEN_TO_SQUARE .. u8(" Редактирование подпункта##") .. chapter.name .. index .. chapter_index, _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize) then
												if imgui.BeginChild('##smartukedititeminput', imgui.ImVec2(489 * MONET_DPI_SCALE, 155 * MONET_DPI_SCALE), true) then	
													imgui.CenterText(u8'Название подпункта:')
													imgui.PushItemWidth(478 * MONET_DPI_SCALE)
													imgui.InputText(u8'##input_smartuk_text', input_smartuk_text, 256)
													imgui.CenterText(u8'Уровень розыска для выдачи (от 1 до 6):')
													imgui.PushItemWidth(478 * MONET_DPI_SCALE)
													imgui.InputText(u8'##input_smartuk_lvl', input_smartuk_lvl, 256)
													imgui.CenterText(u8'Причина для выдачи розыска:')
													imgui.PushItemWidth(478 * MONET_DPI_SCALE)
													imgui.InputText(u8'##input_smartuk_reason', input_smartuk_reason, 256)
													imgui.EndChild()
												end	
												if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
													imgui.CloseCurrentPopup()
												end
												imgui.SameLine()
												if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
													if u8:decode(ffi.string(input_smartuk_lvl)) ~= '' and not u8:decode(ffi.string(input_smartuk_lvl)):find('%D') and tonumber(u8:decode(ffi.string(input_smartuk_lvl))) >= 1 and tonumber(u8:decode(ffi.string(input_smartuk_lvl))) <= 6 and u8:decode(ffi.string(input_smartuk_text)) ~= '' and u8:decode(ffi.string(input_smartuk_reason)) ~= '' then
														item.text = u8:decode(ffi.string(input_smartuk_text))
														item.lvl = u8:decode(ffi.string(input_smartuk_lvl))
														item.reason = u8:decode(ffi.string(input_smartuk_reason))
														save_smart_uk()
														imgui.CloseCurrentPopup()
													else
														sampAddChatMessage('[Justice Helper] {ffffff}Ошибка в указанных данных, исправьте!', message_color)
													end
												end
												imgui.EndPopup()
											end
											imgui.SameLine()
											if imgui.Button(fa.TRASH_CAN .. '##' .. chapter_index .. '##' .. index) then
												imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Justice_Helper - Предупреждение ##' .. chapter_index .. '##' .. index)
											end
											if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Justice_Helper - Предупреждение ##' .. chapter_index .. '##' .. index, _, imgui.WindowFlags.NoResize ) then
												imgui.CenterText(u8'Вы действительно хотите удалить подпункт?')
												imgui.CenterText(u8(item.text))
												imgui.Separator()
												if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
													imgui.CloseCurrentPopup()
												end
												imgui.SameLine()
												if imgui.Button(fa.TRASH_CAN .. u8' Да, удалить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
													table.remove(chapter.item, index)
													save_smart_uk()
													imgui.CloseCurrentPopup()
												end
												imgui.End()
											end
											imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
											imgui.Columns(1)
											imgui.Separator()
										end
									end
									imgui.EndChild()
								end
								if imgui.Button(fa.CIRCLE_PLUS .. u8' Добавить новый подпункт', imgui.ImVec2(imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
									input_smartuk_text = imgui.new.char[256](u8(''))
									input_smartuk_lvl = imgui.new.char[256](u8(''))
									input_smartuk_reason = imgui.new.char[256](u8(''))
									imgui.OpenPopup(fa.CIRCLE_PLUS .. u8(' Добавление нового подпункта'))
								end
								if imgui.BeginPopupModal(fa.CIRCLE_PLUS .. u8(' Добавление нового подпункта'), _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize) then
									if imgui.BeginChild('##smartukedititeminput', imgui.ImVec2(489 * MONET_DPI_SCALE, 155 * MONET_DPI_SCALE), true) then	
										imgui.CenterText(u8'Название подпункта:')
										imgui.PushItemWidth(478 * MONET_DPI_SCALE)
										imgui.InputText(u8'##input_smartuk_text', input_smartuk_text, 256)
										imgui.CenterText(u8'Уровень розыска для выдачи (от 1 до 6):')
										imgui.PushItemWidth(478 * MONET_DPI_SCALE)
										imgui.InputText(u8'##input_smartuk_lvl', input_smartuk_lvl, 256)
										imgui.CenterText(u8'Причина для выдачи розыска:')
										imgui.PushItemWidth(478 * MONET_DPI_SCALE)
										imgui.InputText(u8'##input_smartuk_reason', input_smartuk_reason, 256)
										imgui.EndChild()
									end	
									if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
										imgui.CloseCurrentPopup()
									end
									imgui.SameLine()
									if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
										local text = u8:decode(ffi.string(input_smartuk_text))
										local lvl = u8:decode(ffi.string(input_smartuk_lvl))
										local reason = u8:decode(ffi.string(input_smartuk_reason))
										if lvl ~= '' and not tostring(lvl):find('%D') and tonumber(lvl) >= 1 and tonumber(lvl) <= 6 and text ~= '' and reason ~= '' then
											local temp = { text = text, lvl = lvl, reason = reason }
											table.insert(chapter.item, temp)
											save_smart_uk()
											imgui.CloseCurrentPopup()
										else
											sampAddChatMessage('[Justice Helper] {ffffff}Ошибка в указанных данных, исправьте!', message_color)
										end
									end
									imgui.EndPopup()
								end
								imgui.SameLine()
								if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
									imgui.CloseCurrentPopup()
								end
								imgui.EndPopup()
							end
							imgui.Separator()
						end
						imgui.EndChild()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Добавить пункт', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
							input_smartuk_name = imgui.new.char[256](u8(''))
							imgui.OpenPopup(fa.CIRCLE_PLUS .. u8' Добавление нового пункта')
						end
						if imgui.BeginPopupModal(fa.CIRCLE_PLUS .. u8' Добавление нового пункта', _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize) then
							imgui.CenterText(u8('Введите название/номер пункта и нажмите "Сохранить"'))
							imgui.PushItemWidth(500 * MONET_DPI_SCALE)
							imgui.InputText(u8'##input_smartuk_name', input_smartuk_name, 256)
							imgui.CenterText(u8'Обратите внимание, вы не сможете изменить его в дальнейшем!')
							if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
								imgui.CloseCurrentPopup()
							end
							imgui.SameLine()
							if imgui.Button(fa.CIRCLE_PLUS .. u8' Добавить', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
								local temp = u8:decode(ffi.string(input_smartuk_name))
								local new_chapter = { name = temp, item = {} }
								table.insert(smart_uk, new_chapter)
								save_smart_uk()
								imgui.CloseCurrentPopup()
							end
							imgui.EndPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndPopup()
					end
					imgui.EndChild()
				end
				imgui.SameLine()
				if imgui.BeginChild('##smartpdd', imgui.ImVec2(292 * MONET_DPI_SCALE, 340 * MONET_DPI_SCALE), true) then
					imgui.CenterText(fa.TICKET .. u8' Система умного штрафа')
					imgui.Separator()
					imgui.SetCursorPosY(105 * MONET_DPI_SCALE)
					imgui.SetCursorPosX(105 * MONET_DPI_SCALE)
					if imgui.Button(fa.DOWNLOAD .. u8' Загрузить ##smartpdd') then
						if getARZServerNumber() ~= 0 then
							download_smartpdd = true
							downloadFileFromUrlToPath('https://raw.githubusercontent.com/MTGMODS/justice-helper/main/SmartPDD/' .. getARZServerNumber() .. '/SmartPDD.json', path_pdd)
							imgui.OpenPopup(fa.CIRCLE_INFO .. u8' Justice Helper - Оповещение##donwloadsmartpdd')
						else
							imgui.OpenPopup(fa.CIRCLE_INFO .. u8' Justice Helper - Оповещение##nocloudsmartpdd')
						end
					end
					if imgui.BeginPopupModal(fa.CIRCLE_INFO .. u8' Justice Helper - Оповещение##nocloudsmartpdd', _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize) then
						imgui.CenterText(u8'В базе данных ещё нету умных штрафов для вашего сервера!')
						imgui.Separator()
						imgui.CenterText(u8'Вы можете вручную заполнить его по кнопке "Отредактировать"')
						imgui.CenterText(u8'Затем вы сможете поделиться им на нашем Discord и он будет загружен в базу данных')
						imgui.CenterText(u8'Вам надо будет скинуть файл SmartPDD.json , который находиться по пути:')
						imgui.CenterText(u8(path_pdd))
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Хорошо', imgui.ImVec2(550 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndPopup()
					end
					if imgui.BeginPopupModal(fa.CIRCLE_INFO .. u8' Justice Helper - Оповещение##donwloadsmartpdd', _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize) then
						if download_smartpdd then
							imgui.CenterText(u8'Если вы видите это окно значит идёт скачивание умных штрафов для ' .. getARZServerNumber() .. u8' сервера!')
							imgui.CenterText(u8'После заверешения загрузки это окно пропадёт и вы увидите сообщение в чате!')
							imgui.Separator()
							imgui.CenterText(u8'Если же ничего не происходит, значит произошла ошибка скачивания SmartPDD.json')
							imgui.CenterText(u8'Возможно в базе данных нету файла именно для вашего сервера!')
							imgui.Separator()
							imgui.CenterText(u8'В этом случае вы можете вручную заполнить его по кнопке "Отредактировать"')
							imgui.CenterText(u8'Затем вы сможете поделиться им на нашем Discord и он будет загружен в базу данных')
							imgui.CenterText(u8'Вам надо будет скинуть файл SmartPDD.json , который находиться по пути:')
							imgui.CenterText(u8(path_pdd))
							imgui.Separator()
						else
							imgui.CloseCurrentPopup()
						end
						if imgui.Button(fa.CIRCLE_INFO .. u8' Хорошо', imgui.ImVec2(550 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndPopup()
					end
					imgui.SetCursorPosX(80 * MONET_DPI_SCALE)
					imgui.SetCursorPosY(170 * MONET_DPI_SCALE)
					if imgui.Button(fa.PEN_TO_SQUARE .. u8' Отредактировать ##smartpdd') then
						imgui.OpenPopup(fa.TICKET .. u8' Система умных штрафов##smartpdd')
					end
					if imgui.BeginPopupModal(fa.TICKET .. u8' Система умных штрафов##smartpdd', _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize ) then
						imgui.BeginChild('##smartpddedit', imgui.ImVec2(589 * MONET_DPI_SCALE, 360 * MONET_DPI_SCALE), true)
						for chapter_index, chapter in ipairs(smart_pdd) do
							imgui.Columns(2)
							imgui.BulletText(u8(chapter.name))
							imgui.SetColumnWidth(-1, 515 * MONET_DPI_SCALE)
							imgui.NextColumn()
							if imgui.Button(fa.PEN_TO_SQUARE .. '##smartpdd' .. chapter_index) then
								imgui.OpenPopup(u8(chapter.name).. '##smartpdd' .. chapter_index)
							end
							imgui.SameLine()
							if imgui.Button(fa.TRASH_CAN .. '##smartpdd' .. chapter_index) then
								imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Justice_Helper - Предупреждение ##smartpdd' .. chapter_index)
							end
							if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Justice_Helper - Предупреждение ##smartpdd' .. chapter_index, _, imgui.WindowFlags.NoResize ) then
								imgui.CenterText(u8'Вы действительно хотите удалить пункт?')
								imgui.CenterText(u8(chapter.name))
								imgui.Separator()
								if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
									imgui.CloseCurrentPopup()
								end
								imgui.SameLine()
								if imgui.Button(fa.TRASH_CAN .. u8' Да, удалить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
									table.remove(smart_pdd, chapter_index)
									save_smart_pdd()
									imgui.CloseCurrentPopup()
								end
								imgui.End()
							end
							imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
							imgui.Columns(1)
							if imgui.BeginPopupModal(u8(chapter.name).. '##smartpdd' .. chapter_index, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
								if imgui.BeginChild('##smartpddedititem', imgui.ImVec2(589 * MONET_DPI_SCALE, 390 * MONET_DPI_SCALE), true) then
									if chapter.item then
										for index, item in ipairs(chapter.item) do
											imgui.Columns(2)
											imgui.BulletText(u8(item.text))
											imgui.SetColumnWidth(-1, 515 * MONET_DPI_SCALE)
											imgui.NextColumn()
											if imgui.Button(fa.PEN_TO_SQUARE .. '##' .. chapter_index .. '##smartpdd' .. index) then
												input_smartpdd_text = imgui.new.char[256](u8(item.text))
												input_smartpdd_amount = imgui.new.char[256](u8(item.amount))
												input_smartpdd_reason = imgui.new.char[256](u8(item.reason))
												imgui.OpenPopup(fa.PEN_TO_SQUARE .. u8(" Редактирование подпункта##smartpdd") .. chapter.name .. index .. chapter_index)
											end
											if imgui.BeginPopupModal(fa.PEN_TO_SQUARE .. u8(" Редактирование подпункта##smartpdd") .. chapter.name .. index .. chapter_index, _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize) then
												if imgui.BeginChild('##smartpddedititeminput', imgui.ImVec2(489 * MONET_DPI_SCALE, 155 * MONET_DPI_SCALE), true) then	
													imgui.CenterText(u8'Название подпункта:')
													imgui.PushItemWidth(478 * MONET_DPI_SCALE)
													imgui.InputText(u8'##input_smartpdd_text', input_smartpdd_text, 256)
													imgui.CenterText(u8'Сумма штрафа (цифры без каких либо символов):')
													imgui.PushItemWidth(478 * MONET_DPI_SCALE)
													imgui.InputText(u8'##input_smartpdd_amount', input_smartpdd_amount, 256)
													imgui.CenterText(u8'Причина для выдачи штрафа:')
													imgui.PushItemWidth(478 * MONET_DPI_SCALE)
													imgui.InputText(u8'##input_smartpdd_reason', input_smartpdd_reason, 256)
													imgui.EndChild()
												end	
												if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
													imgui.CloseCurrentPopup()
												end
												imgui.SameLine()
												if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
													if u8:decode(ffi.string(input_smartpdd_amount)) ~= ''and u8:decode(ffi.string(input_smartpdd_text)) ~= '' and u8:decode(ffi.string(input_smartpdd_reason)) ~= '' and u8:decode(ffi.string(input_smartpdd_amount)):find('%d') and not u8:decode(ffi.string(input_smartpdd_amount)):find('%D') then
														item.text = u8:decode(ffi.string(input_smartpdd_text))
														item.amount = u8:decode(ffi.string(input_smartpdd_amount))
														item.reason = u8:decode(ffi.string(input_smartpdd_reason))
														save_smart_pdd()
														imgui.CloseCurrentPopup()
													else
														sampAddChatMessage('[Justice Helper] {ffffff}Ошибка в указанных данных, исправьте!', message_color)
													end
												end
												imgui.EndPopup()
											end
											imgui.SameLine()
											if imgui.Button(fa.TRASH_CAN .. '##' .. chapter_index .. '###smartpdd' .. index) then
												imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Justice_Helper - Предупреждение ##smartpdd' .. chapter_index .. '##' .. index)
											end
											if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Justice_Helper - Предупреждение ##smartpdd' .. chapter_index .. '##' .. index, _, imgui.WindowFlags.NoResize ) then
												imgui.CenterText(u8'Вы действительно хотите удалить подпункт?')
												imgui.CenterText(u8(item.text))
												imgui.Separator()
												if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
													imgui.CloseCurrentPopup()
												end
												imgui.SameLine()
												if imgui.Button(fa.TRASH_CAN .. u8' Да, удалить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
													table.remove(chapter.item, index)
													save_smart_pdd()
													imgui.CloseCurrentPopup()
												end
												imgui.End()
											end
											imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
											imgui.Columns(1)
											imgui.Separator()
										end
									end
									imgui.EndChild()
								end
								if imgui.Button(fa.CIRCLE_PLUS .. u8' Добавить новый подпункт##smartpdd', imgui.ImVec2(imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
									input_smartpdd_text = imgui.new.char[256](u8(''))
									input_smartpdd_amount = imgui.new.char[256](u8(''))
									input_smartpdd_reason = imgui.new.char[256](u8(''))
									imgui.OpenPopup(fa.CIRCLE_PLUS .. u8(' Добавление нового подпункта##smartpdd'))
								end
								if imgui.BeginPopupModal(fa.CIRCLE_PLUS .. u8(' Добавление нового подпункта##smartpdd'), _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize) then
									if imgui.BeginChild('##smartpddedititeminput', imgui.ImVec2(489 * MONET_DPI_SCALE, 155 * MONET_DPI_SCALE), true) then	
										imgui.CenterText(u8'Название подпункта:')
										imgui.PushItemWidth(478 * MONET_DPI_SCALE)
										imgui.InputText(u8'##input_smartpdd_text', input_smartpdd_text, 256)
										imgui.CenterText(u8'Сумма штрафа (цифры без каких либо символов):')
										imgui.PushItemWidth(478 * MONET_DPI_SCALE)
										imgui.InputText(u8'##input_smartpdd_amount', input_smartpdd_amount, 256)
										imgui.CenterText(u8'Причина для выдачи штрафа:')
										imgui.PushItemWidth(478 * MONET_DPI_SCALE)
										imgui.InputText(u8'##input_smartpdd_reason', input_smartpdd_reason, 256)
										imgui.EndChild()
									end	
									if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
										imgui.CloseCurrentPopup()
									end
									imgui.SameLine()
									if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
										local text = u8:decode(ffi.string(input_smartpdd_text))
										local amount = u8:decode(ffi.string(input_smartpdd_amount))
										local reason = u8:decode(ffi.string(input_smartpdd_reason))
										if amount ~= ''and text ~= '' and reason ~= '' and tostring(amount):find('%d') and not tostring(amount):find('%D') then
											local temp = { text = text, amount = amount, reason = reason }
											table.insert(chapter.item, temp)
											save_smart_pdd()
											imgui.CloseCurrentPopup()
										else
											sampAddChatMessage('[Justice Helper] {ffffff}Ошибка в указанных данных, исправьте!', message_color)
										end
									end
									imgui.EndPopup()
								end
								imgui.SameLine()
								if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
									imgui.CloseCurrentPopup()
								end
								imgui.EndPopup()
							end
							imgui.Separator()
						end
						imgui.EndChild()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Добавить пункт', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
							input_smartpdd_name = imgui.new.char[256](u8(''))
							imgui.OpenPopup(fa.CIRCLE_PLUS .. u8' Добавление нового пункта##smartpdd')
						end
						if imgui.BeginPopupModal(fa.CIRCLE_PLUS .. u8' Добавление нового пункта##smartpdd', _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize) then
							imgui.CenterText(u8('Введите название/номер пункта и нажмите "Сохранить"'))
							imgui.PushItemWidth(500 * MONET_DPI_SCALE)
							imgui.InputText(u8'##input_smartpdd_name', input_smartpdd_name, 256)
							imgui.CenterText(u8'Обратите внимание, вы не сможете изменить его в дальнейшем!')
							if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
								imgui.CloseCurrentPopup()
							end
							imgui.SameLine()
							if imgui.Button(fa.CIRCLE_PLUS .. u8' Добавить', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
								local temp = u8:decode(ffi.string(input_smartpdd_name))
								local new_chapter = { name = temp, item = {} }
								table.insert(smart_pdd, new_chapter)
								save_smart_pdd()
								imgui.CloseCurrentPopup()
							end
							imgui.EndPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndPopup()
					end
					imgui.SetCursorPosY(250 * MONET_DPI_SCALE)
					imgui.CenterText(u8('Использование: /tsm [ID игрока]'))
					imgui.EndChild()
				end
				imgui.CenterText(u8'Предложения по изменению облачного розыска/штрафов отправляйте в Discord или BlastHack.')
			imgui.EndTabItem()
			end
			if imgui.BeginTabItem(fa.FILE_PEN..u8' Заметки') then 
			 	imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 330 * MONET_DPI_SCALE), true)
				imgui.Columns(2)
				imgui.CenterColumnText(u8"Список всех ваших заметок/шпаргалок:")
				imgui.SetColumnWidth(-1, 495 * MONET_DPI_SCALE)
				imgui.NextColumn()
				imgui.CenterColumnText(u8"Действие")
				imgui.SetColumnWidth(-1, 150 * MONET_DPI_SCALE)
				imgui.Columns(1)
				imgui.Separator()
				for i, note in ipairs(notes.note) do
					imgui.Columns(2)
					imgui.CenterColumnText(u8(note.note_name))
					imgui.NextColumn()
					if imgui.SmallButton(fa.UP_RIGHT_FROM_SQUARE .. '##' .. i) then
						show_note_name = u8(note.note_name)
						show_note_text = u8(note.note_text)
						NoteWindow[0] = true
					end
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8'Открыть заметку "' .. u8(note.note_name) .. '"')
					end
					imgui.SameLine()
					if imgui.SmallButton(fa.PEN_TO_SQUARE .. '##' .. i) then
						local note_text = note.note_text:gsub('&','\n')
						input_text_note = imgui.new.char[16384](u8(note_text))
						input_name_note = imgui.new.char[256](u8(note.note_name))
						imgui.OpenPopup(fa.PEN_TO_SQUARE .. u8' Изменение заметки' .. '##' .. i)	
					end
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8'Редактирование заметки "' .. u8(note.note_name) .. '"')
					end
					if imgui.BeginPopupModal(fa.PEN_TO_SQUARE .. u8' Изменение заметки' .. '##' .. i, _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize ) then
						if imgui.BeginChild('##9992', imgui.ImVec2(589 * MONET_DPI_SCALE, 360 * MONET_DPI_SCALE), true) then	
							imgui.PushItemWidth(578 * MONET_DPI_SCALE)
							imgui.InputText(u8'##note_name', input_name_note, 256)
							imgui.InputTextMultiline("##note_text", input_text_note, 16384, imgui.ImVec2(578 * MONET_DPI_SCALE, 320 * MONET_DPI_SCALE))
							imgui.EndChild()
						end	
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить заметку', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
							note.note_name = u8:decode(ffi.string(input_name_note))
							local temp = u8:decode(ffi.string(input_text_note))
							note.note_text = temp:gsub('\n', '&')
							save_notes()
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.SameLine()
					if imgui.SmallButton(fa.TRASH_CAN .. '##' .. i) then
						imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##' .. note.note_name)
					end
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8'Удаление заметки "' .. u8(note.note_name) .. '"')
					end
					if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##' .. note.note_name, _, imgui.WindowFlags.NoResize ) then
						imgui.CenterText(u8'Вы действительно хотите удалить заметку "' .. u8(note.note_name) .. '" ?')
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.TRASH_CAN .. u8' Да, удалить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							table.remove(notes.note, i)
							save_notes()
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.Columns(1)
					imgui.Separator()
				end
				imgui.EndChild()
				if imgui.Button(fa.CIRCLE_PLUS .. u8' Создать новую заметку', imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then
					input_name_note = imgui.new.char[256](u8("Название"))
					input_text_note = imgui.new.char[16384](u8("Текст"))
					imgui.OpenPopup(fa.PEN_TO_SQUARE .. u8' Создание заметки')	
				end
				if imgui.BeginPopupModal(fa.PEN_TO_SQUARE .. u8' Создание заметки', _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize ) then
					if imgui.BeginChild('##999999', imgui.ImVec2(589 * MONET_DPI_SCALE, 360 * MONET_DPI_SCALE), true) then	
						imgui.PushItemWidth(578 * MONET_DPI_SCALE)
						imgui.InputText(u8'##note_name', input_name_note, 256)
						imgui.InputTextMultiline("##note_text", input_text_note, 16384, imgui.ImVec2(578 * MONET_DPI_SCALE, 320 * MONET_DPI_SCALE))
						imgui.EndChild()
					end	
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SameLine()
					if imgui.Button(fa.FLOPPY_DISK .. u8' Создать заметку', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
						local temp = u8:decode(ffi.string(input_text_note))
						local new_note = {note_name = u8:decode(ffi.string(input_name_note)), note_text = temp:gsub('\n', '&') }
						table.insert(notes.note, new_note)
						save_notes()
						imgui.CloseCurrentPopup()
					end
					imgui.End()
				end
				imgui.EndTabItem()
			end
			if imgui.BeginTabItem(fa.GEAR..u8' Настройки') then 
				imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 170 * MONET_DPI_SCALE), true)
				imgui.CenterText(fa.CIRCLE_INFO .. u8' Дополнительная информация про хелпер')
				imgui.Separator()
				imgui.Text(fa.CIRCLE_USER..u8" Разработчик данного хелпера: MTG MODS")
				imgui.Separator()
				imgui.Text(fa.CIRCLE_INFO..u8" Установленная версия хелпера: " .. u8(thisScript().version))
				imgui.SameLine()
				if imgui.SmallButton(u8'Проверить обновления') then
					check_update()
				end
				imgui.Separator()
				imgui.Text(fa.BOOK ..u8" Гайд по использованию хелпера:")
				imgui.SameLine()
				if imgui.SmallButton(u8'Будет позже...') then
					-- openLink('')
				end
				imgui.Separator()
				imgui.Text(fa.HEADSET..u8" Тех.поддержка по хелперу:")
				imgui.SameLine()
				if imgui.SmallButton('https://discord.gg/mtg-mods-samp-1097643847774908526') then
					openLink('https://discord.gg/mtg-mods-samp-1097643847774908526')
				end
				imgui.Separator()
				imgui.Text(fa.GLOBE..u8" Тема хелпера на форуме BlastHack:")
				imgui.SameLine()
				if imgui.SmallButton(u8'Будет позже...') then
					--openLink('https://www.blast.hk/')
				end
				imgui.Separator()
				imgui.Text(fa.HAND_HOLDING_DOLLAR .. u8" Поддержать разработчика донатом:")
				imgui.SameLine()
				if imgui.SmallButton(u8'Получить реквизиты') then
					imgui.OpenPopup(fa.SACK_DOLLAR .. u8' Поддержка разработчика')
				end
				if imgui.BeginPopupModal(fa.SACK_DOLLAR .. u8' Поддержка разработчика', _, imgui.WindowFlags.NoCollapse  + imgui.WindowFlags.NoResize ) then
					imgui.CenterText(u8'Реквизиты указаны на нашем Discord сервере тех.поддержки')
					imgui.CenterText(u8'Если же вы не можете зайти туда, то свяжитесь с MTG MODS:')
					imgui.SetCursorPosX(130*MONET_DPI_SCALE)
					if imgui.Button(u8('Telegram')) then
						openLink('https://t.me/mtg_mods')
					end
					imgui.SameLine()
					if imgui.Button(u8('Discord')) then
						openLink('https://discordapp.com/users/514135796685602827')
					end
					imgui.SameLine()
					if imgui.Button(u8('VK')) then
						openLink('https://vk.com/mtgmods')
					end
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(400 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
						imgui.CloseCurrentPopup()
					end
					imgui.End()
				end
				imgui.EndChild()
				imgui.BeginChild('##3', imgui.ImVec2(589 * MONET_DPI_SCALE, 87 * MONET_DPI_SCALE), true)
				imgui.CenterText(fa.PALETTE .. u8' Цветовая тема хелпера:')
				imgui.Separator()
				if imgui.RadioButtonIntPtr(u8" Dark Theme ", theme, 0) then	
					theme[0] = 0
                    message_color = 0x009EFF
                    message_color_hex = '{009EFF}'
					settings.general.moonmonet_theme_enable = false
					save_settings()
					
					apply_dark_theme()
				end
				if monet_no_errors then
					if imgui.RadioButtonIntPtr(u8" MoonMonet Theme ", theme, 1) then
						theme[0] = 1
						local r,g,b = mmcolor[0] * 255, mmcolor[1] * 255, mmcolor[2] * 255
						local argb = join_argb(0, r, g, b)
						settings.general.moonmonet_theme_enable = true
						settings.general.moonmonet_theme_color = argb
						message_color = "0x" .. argbToHexWithoutAlpha(0, r, g, b)
						message_color_hex = '{' .. argbToHexWithoutAlpha(0, r, g, b) .. '}'
						apply_moonmonet_theme()
						save_settings()
					end
					imgui.SameLine()
					if theme[0] == 1 and imgui.ColorEdit3('## COLOR', mmcolor, imgui.ColorEditFlags.NoInputs) then
						local r,g,b = mmcolor[0] * 255, mmcolor[1] * 255, mmcolor[2] * 255
						local argb = join_argb(0, r, g, b)
						-- settings.general.message_color = 
						-- settings.general.message_color_hex = 
						settings.general.moonmonet_theme_color = argb
						message_color = "0x" .. argbToHexWithoutAlpha(0, r, g, b)
						message_color_hex = '{' .. argbToHexWithoutAlpha(0, r, g, b) .. '}'
						if theme[0] == 1 then
							apply_moonmonet_theme()
							save_settings()
						end
					end
				else
					if imgui.RadioButtonIntPtr(u8" MoonMonet Theme | "..fa.TRIANGLE_EXCLAMATION .. u8' Ошибка: отсуствуют файлы библиотеки!', theme, 1) then
						theme[0] = 0
					end
				end
				imgui.EndChild()
				imgui.BeginChild("##2",imgui.ImVec2(589 * MONET_DPI_SCALE, 55 * MONET_DPI_SCALE),true)
				-- imgui.TextWrapped(u8('Нашли баг или есть предложение по улучшению хелпера? Сообщите об этом на нашем Discord сервере или на форуме BlastHack!'))
				-- imgui.TextWrapped(u8('Есть желание  Вы можете закинуть донатик! Реквизиты есть на нашем Discord сервере.'))
				imgui.CenterText(u8'Нашли баг или есть предложение по улучшению хелпера?')
				imgui.Separator()
				imgui.CenterText(u8'Сообщите об этом на нашем Discord сервере или на форуме BlastHack!')
				imgui.EndChild()
				imgui.BeginChild("##4",imgui.ImVec2(589 * MONET_DPI_SCALE, 35 * MONET_DPI_SCALE),true)
				if imgui.Button(fa.POWER_OFF .. u8" Выключение ", imgui.ImVec2(imgui.GetMiddleButtonX(4), 25 * MONET_DPI_SCALE)) then
					imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##off')
				end
				if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##off', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar ) then

					imgui.CenterText(u8'Вы действительно хотите выгрузить (отключить) хелпер?')
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SameLine()
					if imgui.Button(fa.POWER_OFF .. u8' Да, выгрузить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
						reload_script = true
						play_error_sound()
						sampAddChatMessage('[Justice Helper] {ffffff}Хелпер приостановил свою работу до следущего входа в игру!', message_color)
						if not isMonetLoader() then 
							sampAddChatMessage('[Justice Helper] {ffffff}Либо используйте ' .. message_color_hex .. 'CTRL {ffffff}+ ' .. message_color_hex .. 'R {ffffff}чтобы запустить хелпер.', message_color)
						end
						thisScript():unload()
					end
					imgui.End()
				end
				imgui.SameLine()
				if imgui.Button(fa.ROTATE_RIGHT .. u8" Перезагрузка ", imgui.ImVec2(imgui.GetMiddleButtonX(4), 25 * MONET_DPI_SCALE)) then
					reload_script = true
					thisScript():reload()
				end
				imgui.SameLine()
				if imgui.Button(fa.CLOCK_ROTATE_LEFT .. u8" Сброс настроек ", imgui.ImVec2(imgui.GetMiddleButtonX(4), 25 * MONET_DPI_SCALE)) then
					imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##reset')
				end
				if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##reset', _, imgui.WindowFlags.NoResize ) then
					imgui.CenterText(u8'Вы действительно хотите сбросить все настройки хелпера?')
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SameLine()
					if imgui.Button(fa.CLOCK_ROTATE_LEFT .. u8' Да, сбросить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
						play_error_sound()
						os.remove(path_uk)
						os.remove(path_pdd)
						os.remove(path_notes)
						os.remove(path_settings)
						os.remove(path_commands)
						imgui.CloseCurrentPopup()
						reload_script = true
						thisScript():reload()
					end
					imgui.End()
				end
				imgui.SameLine()
				if imgui.Button(fa.TRASH_CAN .. u8" Удаление ", imgui.ImVec2(imgui.GetMiddleButtonX(4), 25 * MONET_DPI_SCALE)) then
					imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##delete')
				end
				if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##delete', _, imgui.WindowFlags.NoResize ) then
					imgui.CenterText(u8'Вы действительно хотите удалить Justice Helper?')
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SameLine()
					if imgui.Button(fa.TRASH_CAN .. u8' Да, я хочу удалить', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
						sampAddChatMessage('[Justice Helper] {ffffff}Хелпер полностю удалён из вашего устройства!', message_color)
						sampShowDialog(999999, message_color_hex .. "Justice Helper", "Мне очень жаль что вы удалили Justice Helper из своего устройства.\nЕсли удаление связано с негативным опытом использования, и вы сталкивались с багами или проблемами, то\nсообщите мне что именно заставило вас удалить хелпер на нашем Discord сервере или на форуме BlastHack\n\nDiscord: https://discord.com/invite/qBPEYjfNhv\nBlastHack: https://www.blast.hk/threads/195388/\n\nЕсли что, вы можете заново скачать и установить хелпер в любой момент :)", "Закрыть", '', 0)
						reload_script = true
						play_error_sound()
						os.remove(path_helper)
						os.remove(path_settings)
						os.remove(path_commands)
						os.remove(path_uk)
						os.remove(path_pdd)
						os.remove(path_notes)
						thisScript():unload()
					end
					imgui.End()
				end
				imgui.EndChild()
				imgui.EndTabItem()
			end
		imgui.EndTabBar() end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return DeportamentWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.WALKIE_TALKIE .. u8" Рация депортамента", DeportamentWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
		imgui.BeginChild('##2', imgui.ImVec2(589 * MONET_DPI_SCALE, 160 * MONET_DPI_SCALE), true)
		imgui.Columns(3)
		imgui.CenterColumnText(u8('Ваш тег:'))
		imgui.PushItemWidth(215 * MONET_DPI_SCALE)
		if imgui.InputText('##input_dep_tag1', input_dep_tag1, 256) then
			settings.deportament.dep_tag1 = u8:decode(ffi.string(input_dep_tag1))
			save_settings()
		end
		if imgui.CenterColumnButton(u8('Выбрать тег##1')) then
			imgui.OpenPopup(fa.TAG .. u8' Теги организаций##1')
		end
		if imgui.BeginPopupModal(fa.TAG .. u8' Теги организаций##1', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
			if imgui.BeginTabBar('TabTags') then
				if imgui.BeginTabItem(fa.BARS..u8' Стандартные теги (ru) ') then 
					local line_started = false
					for i, tag in ipairs(settings.deportament.dep_tags) do
						if tag ~= 'skip' then
							if line_started then
								imgui.SameLine()
							else
								line_started = true
							end
							if imgui.Button(' ' .. u8(tag) .. ' ##' .. i) then
								input_dep_tag1 = imgui.new.char[256](u8(tag))
								settings.deportament.dep_tag1 = u8:decode(ffi.string(input_dep_tag1))
								save_settings()
								imgui.CloseCurrentPopup()
							end
						else
							line_started = false
						end
					end
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2( imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
						imgui.CloseCurrentPopup()
					end
				imgui.EndTabItem() end
				if imgui.BeginTabItem(fa.BARS..u8' Стандартные теги (en) ') then 
					local line_started = false
					for i, tag in ipairs(settings.deportament.dep_tags_en) do
						if tag ~= 'skip' then
							if line_started then
								imgui.SameLine()
							else
								line_started = true
							end
							if imgui.Button(' ' .. u8(tag) .. ' ##' .. i) then
								input_dep_tag1 = imgui.new.char[256](u8(tag))
								settings.deportament.dep_tag1 = u8:decode(ffi.string(input_dep_tag1))
								save_settings()
								imgui.CloseCurrentPopup()
							end
						else
							line_started = false
						end
					end
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2( imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
						imgui.CloseCurrentPopup()
					end
				imgui.EndTabItem() end
				if imgui.BeginTabItem(fa.BARS..u8' Ваши кастомные теги ') then 
					local line_started = false
					for i, tag in ipairs(settings.deportament.dep_tags_custom) do
						if tag ~= 'skip' then
							if line_started then
								imgui.SameLine()
							else
								line_started = true
							end
							if imgui.Button(' ' .. u8(tag) .. ' ##' .. i) then
								input_dep_tag1 = imgui.new.char[256](u8(tag))
								settings.deportament.dep_tag1 = u8:decode(ffi.string(input_dep_tag1))
								save_settings()
								imgui.CloseCurrentPopup()
							end
						else
							line_started = false
						end
					end
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_PLUS .. u8' Добавить тег', imgui.ImVec2( imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
						imgui.OpenPopup(fa.TAG .. u8' Добавление нового тега##1')	
					end
					if imgui.BeginPopupModal(fa.TAG .. u8' Добавление нового тега##1', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
						imgui.PushItemWidth(215 * MONET_DPI_SCALE)
						imgui.InputText('##input_dep_new_tag', input_dep_new_tag, 256) 
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2( imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2( imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
							table.insert(settings.deportament.dep_tags_custom, u8:decode(ffi.string(input_dep_new_tag)))
							save_settings()
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.SameLine()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2( imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
						imgui.CloseCurrentPopup()
					end
				imgui.EndTabItem() end
			imgui.EndTabBar() 
			end
			imgui.End()
		end
		imgui.SetColumnWidth(-1, 230 * MONET_DPI_SCALE)
		imgui.NextColumn()
		imgui.CenterColumnText(u8('Частота рации:'))
		imgui.PushItemWidth(140 * MONET_DPI_SCALE)
		if imgui.InputText('##input_dep_fm', input_dep_fm, 256) then
			settings.deportament.dep_fm = u8:decode(ffi.string(input_dep_fm))
			save_settings()
		end
		if imgui.CenterColumnButton(u8('Выбрать частоту##1')) then
			imgui.OpenPopup(fa.WALKIE_TALKIE .. u8' Частота рации /d')
		end
		if imgui.BeginPopupModal(fa.WALKIE_TALKIE .. u8' Частота рации /d', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
			for i, tag in ipairs(settings.deportament.dep_fms) do
				imgui.SameLine()
				if imgui.Button(' ' .. u8(tag) .. ' ##' .. i) then
					input_dep_fm = imgui.new.char[256](u8(tag))
					settings.deportament.dep_fm = u8:decode(ffi.string(input_dep_fm))
					save_settings()
					imgui.CloseCurrentPopup()
				end
			end
			imgui.Separator()
			if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2( imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
				imgui.CloseCurrentPopup()
			end
			imgui.End()
		end
		imgui.SetColumnWidth(-1, 150 * MONET_DPI_SCALE)
		imgui.NextColumn()
		imgui.CenterColumnText(u8('Тег, к кому вы обращаетесь:'))
		imgui.PushItemWidth(195 * MONET_DPI_SCALE)
		if imgui.InputText('##input_dep_tag2', input_dep_tag2, 256) then
			settings.deportament.dep_tag2 = u8:decode(ffi.string(input_dep_tag2))
			save_settings()
		end
		if imgui.CenterColumnButton(u8('Выбрать тег##2')) then
			imgui.OpenPopup(fa.TAG .. u8' Теги организаций##2')
		end
		if imgui.BeginPopupModal(fa.TAG .. u8' Теги организаций##2', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
			if imgui.BeginTabBar('TabTags') then
				if imgui.BeginTabItem(fa.BARS..u8' Стандартные теги (ru) ') then 
					local line_started = false
					for i, tag in ipairs(settings.deportament.dep_tags) do
						if tag ~= 'skip' then
							if line_started then
								imgui.SameLine()
							else
								line_started = true
							end
							if imgui.Button(' ' .. u8(tag) .. ' ##' .. i) then
								input_dep_tag2 = imgui.new.char[256](u8(tag))
								settings.deportament.dep_tag2 = u8:decode(ffi.string(input_dep_tag2))
								save_settings()
								imgui.CloseCurrentPopup()
							end
						else
							line_started = false
						end
					end
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2( imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
						imgui.CloseCurrentPopup()
					end
				imgui.EndTabItem() end
				if imgui.BeginTabItem(fa.BARS..u8' Стандартные теги (en) ') then 
					local line_started = false
					for i, tag in ipairs(settings.deportament.dep_tags_en) do
						if tag ~= 'skip' then
							if line_started then
								imgui.SameLine()
							else
								line_started = true
							end
							if imgui.Button(' ' .. u8(tag) .. ' ##' .. i) then
								input_dep_tag2 = imgui.new.char[256](u8(tag))
								settings.deportament.dep_tag2 = u8:decode(ffi.string(input_dep_tag2))
								save_settings()
								imgui.CloseCurrentPopup()
							end
						else
							line_started = false
						end
					end
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2( imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
						imgui.CloseCurrentPopup()
					end
				imgui.EndTabItem() end
				if imgui.BeginTabItem(fa.BARS..u8' Ваши кастомные теги ') then 
					local line_started = false
					for i, tag in ipairs(settings.deportament.dep_tags_custom) do
						if tag ~= 'skip' then
							if line_started then
								imgui.SameLine()
							else
								line_started = true
							end
							if imgui.Button(' ' .. u8(tag) .. ' ##' .. i) then
								input_dep_tag2 = imgui.new.char[256](u8(tag))
								settings.deportament.dep_tag2 = u8:decode(ffi.string(input_dep_tag2))
								save_settings()
								imgui.CloseCurrentPopup()
							end
						else
							line_started = false
						end
					end
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_PLUS .. u8' Добавить тег', imgui.ImVec2( imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
						imgui.OpenPopup(fa.TAG .. u8' Добавление нового тега##2')	
					end
					if imgui.BeginPopupModal(fa.TAG .. u8' Добавление нового тега##2', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
						imgui.PushItemWidth(215 * MONET_DPI_SCALE)
						imgui.InputText('##input_dep_new_tag', input_dep_new_tag, 256) 
						imgui.Separator()
						if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2( imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2( imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
							table.insert(settings.deportament.dep_tags_custom, u8:decode(ffi.string(input_dep_new_tag)))
							save_settings()
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.SameLine()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2( imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
						imgui.CloseCurrentPopup()
					end
				imgui.EndTabItem() end
			imgui.EndTabBar() 
			end
			imgui.End()
		end
		imgui.SetColumnWidth(-1, 235 * MONET_DPI_SCALE)
		imgui.Columns(1)
		imgui.Separator()
		imgui.CenterText(u8('Текст:'))
		imgui.PushItemWidth(490 * MONET_DPI_SCALE)
		imgui.InputText(u8'##dep_input_text', input_dep_text, 256)
		imgui.SameLine()
		if imgui.Button(u8' Отправить ') then
			sampSendChat('/d ' .. u8:decode(ffi.string(input_dep_tag1)) .. ' ' .. u8:decode(ffi.string(input_dep_fm)) .. ' ' ..  u8:decode(ffi.string(input_dep_tag2)) .. ' '  .. u8:decode(ffi.string(input_dep_text)))
		end
		imgui.Separator()
		imgui.CenterText(u8'Предпросмотр: /d ' .. u8(u8:decode(ffi.string(input_dep_tag1))) .. ' ' .. u8(u8:decode(ffi.string(input_dep_fm))) .. ' ' ..  u8(u8:decode(ffi.string(input_dep_tag2))) .. ' '  .. u8(u8:decode(ffi.string(input_dep_text))) )
		imgui.EndChild()
		imgui.End()
    end
)

imgui.OnFrame(
    function() return BinderWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, 425	* MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.PEN_TO_SQUARE .. u8' Редактирование команды /' .. change_cmd, BinderWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  )
		if imgui.BeginChild('##binder_edit', imgui.ImVec2(589 * MONET_DPI_SCALE, 361 * MONET_DPI_SCALE), true) then
			imgui.CenterText(fa.FILE_LINES .. u8' Описание команды:')
			imgui.PushItemWidth(579 * MONET_DPI_SCALE)
			imgui.InputText("##input_description", input_description, 256)
			imgui.Separator()
			imgui.CenterText(fa.TERMINAL .. u8' Команда для использования в чате (без /):')
			imgui.PushItemWidth(579 * MONET_DPI_SCALE)
			imgui.InputText("##input_cmd", input_cmd, 256)
			imgui.Separator()
			imgui.CenterText(fa.CODE .. u8' Аргументы которые принимает команда:')
	    	imgui.Combo(u8'',ComboTags, ImItems, #item_list)
	 	    imgui.Separator()
	        imgui.CenterText(fa.FILE_WORD .. u8' Текстовый бинд команды:')
			imgui.InputTextMultiline("##text_multiple", input_text, 8192, imgui.ImVec2(579 * MONET_DPI_SCALE, 173 * MONET_DPI_SCALE))
		imgui.EndChild() end
		if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(imgui.GetMiddleButtonX(5), 0)) then
			BinderWindow[0] = false
		end
		imgui.SameLine()
		if imgui.Button(fa.CLOCK .. u8' Задержка',imgui.ImVec2(imgui.GetMiddleButtonX(5), 0)) then
			imgui.OpenPopup(fa.CLOCK .. u8' Задержка (в секундах) ')
		end
		if imgui.BeginPopupModal(fa.CLOCK .. u8' Задержка (в секундах) ', _, imgui.WindowFlags.NoResize ) then
			imgui.PushItemWidth(200 * MONET_DPI_SCALE)
			imgui.SliderFloat(u8'##waiting', waiting_slider, 0.3, 5)
			imgui.Separator()
			if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
				waiting_slider = imgui.new.float(tonumber(change_waiting))	
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(imgui.GetMiddleButtonX(2), 0)) then
				imgui.CloseCurrentPopup()
			end
			imgui.End()
		end
		imgui.SameLine()
		if imgui.Button(fa.TAGS .. u8' Тэги (1)', imgui.ImVec2(imgui.GetMiddleButtonX(5), 0)) then
			imgui.OpenPopup(fa.TAGS .. u8' Основные тэги для использования в биндере')
		end
		if imgui.BeginPopupModal(fa.TAGS .. u8' Основные тэги для использования в биндере', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize ) then
			imgui.Text(u8(binder_tags_text))
			imgui.Separator()
			if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then
				imgui.CloseCurrentPopup()
			end
			imgui.End()
		end
		imgui.SameLine()
		if imgui.Button(fa.TAGS .. u8' Тэги (2)', imgui.ImVec2(imgui.GetMiddleButtonX(5), 0)) then
			imgui.OpenPopup(fa.TAGS .. u8' Дополнительные тэги для взаимодействия с кодом')
		end
		if imgui.BeginPopupModal(fa.TAGS .. u8' Дополнительные тэги для взаимодействия с кодом', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.CenterText(u8'Использовать очень акуратно, иначе можете что-то сломать!')
			imgui.Separator()
			imgui.Text(u8(binder_tags_text2))
			imgui.Separator()
			if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then
				imgui.CloseCurrentPopup()
			end
			imgui.End()
		end
		imgui.SameLine()
		if imgui.Button(fa.FLOPPY_DISK .. u8' Сохранить', imgui.ImVec2(imgui.GetMiddleButtonX(5), 0)) then	
			if ffi.string(input_cmd):find('%W') or ffi.string(input_cmd) == '' or ffi.string(input_description) == '' or ffi.string(input_text) == '' then
				imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Ошибка сохранения команды!')
			else
				local new_arg = ''
				if ComboTags[0] == 0 then
					new_arg = ''
				elseif ComboTags[0] == 1 then
					new_arg = '{arg}'
				elseif ComboTags[0] == 2 then
					new_arg = '{arg_id}'
				elseif ComboTags[0] == 3 then
					new_arg = '{arg_id} {arg2}'
                elseif ComboTags[0] == 4 then
					new_arg = '{arg_id} {arg2} {arg3}'
				end
				local new_waiting = waiting_slider[0]
				local new_description = u8:decode(ffi.string(input_description))
				local new_command = u8:decode(ffi.string(input_cmd))
				local new_text = u8:decode(ffi.string(input_text)):gsub('\n', '&')
				local temp_array = {}
				if binder_create_command_9_10 then
					temp_array = commands.commands_manage
					binder_create_command_9_10 = false
				else
					temp_array = commands.commands
				end
				for _, command in ipairs(temp_array) do
					if command.cmd == change_cmd and command.description == change_description and command.arg == change_arg and command.text:gsub('&', '\n') == change_text then
						command.cmd = new_command
						command.arg = new_arg
						command.description = new_description
						command.text = new_text
						command.waiting = new_waiting
						save_commands()
						if command.arg == '' then
							sampAddChatMessage('[Justice Helper] {ffffff}Команда ' .. message_color_hex .. '/' .. new_command .. ' {ffffff}успешно сохранена!', message_color)
						elseif command.arg == '{arg}' then
							sampAddChatMessage('[Justice Helper] {ffffff}Команда ' .. message_color_hex .. '/' .. new_command .. ' [аргумент] {ffffff}успешно сохранена!', message_color)
						elseif command.arg == '{arg_id}' then
							sampAddChatMessage('[Justice Helper] {ffffff}Команда ' .. message_color_hex .. '/' .. new_command .. ' [ID игрока] {ffffff}успешно сохранена!', message_color)
						elseif command.arg == '{arg_id} {arg2}' then
							sampAddChatMessage('[Justice Helper] {ffffff}Команда ' .. message_color_hex .. '/' .. new_command .. ' [ID игрока] [аргумент] {ffffff}успешно сохранена!', message_color)
						elseif command.arg == '{arg_id} {arg2} {arg3}' then
							sampAddChatMessage('[Justice Helper] {ffffff}Команда ' .. message_color_hex .. '/' .. new_command .. ' [ID игрока] [аргумент] [аргумент] {ffffff}успешно сохранена!', message_color)
						end
						sampUnregisterChatCommand(change_cmd)
						register_command(command.cmd, command.arg, command.text, tonumber(command.waiting))
						break
					end
				end
				BinderWindow[0] = false
			end
		end
		if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Ошибка сохранения команды!', _, imgui.WindowFlags.AlwaysAutoResize ) then
			if ffi.string(input_cmd):find('%W') then
				imgui.BulletText(u8" В команде можно использовать только англ. буквы и/или цифры!")
			elseif ffi.string(input_cmd) == '' then
				imgui.BulletText(u8" Команда не может быть пустая!")
			end
			if ffi.string(input_description) == '' then
				imgui.BulletText(u8" Описание команды не может быть пустое!")
			end
			if ffi.string(input_text) == '' then
				imgui.BulletText(u8" Бинд команды не может быть пустой!")
			end
			imgui.Separator()
			if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(300 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
				imgui.CloseCurrentPopup()
			end
			imgui.End()
		end	
		imgui.End()
    end
)

imgui.OnFrame(
    function() return MembersWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		if tonumber(#members) >= 16 then
			sizeYY = 413
		else
			sizeYY = 24.5 * ( tonumber(#members) + 1 )
		end
		imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, sizeYY * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		--imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, 413 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)

		imgui.Begin(fa.BUILDING_SHIELD .. " " ..  u8(members_fraction) .. " - " .. #members .. u8' сотрудников онлайн', MembersWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize )
		for i, v in ipairs(members) do
			imgui.Columns(3)
			if v.working then
				imgui_RGBA = imgui.ImVec4(1, 1, 1, 1) -- white
			else
				imgui_RGBA = imgui.ImVec4(1, 0.231, 0.231, 1) -- red
			end
			if tonumber(v.afk) > 0 and tonumber(v.afk) < 60 then
				imgui.CenterColumnColorText(imgui_RGBA, u8(v.nick) .. ' [' .. v.id .. '] [AFK ' .. v.afk .. 's]')
			elseif tonumber(v.afk) >= 60 then
				imgui.CenterColumnColorText(imgui_RGBA, u8(v.nick) .. ' [' .. v.id .. '] [AFK ' .. math.floor( tonumber(v.afk) / 60 ) .. 'm]')
			else
				imgui.CenterColumnColorText(imgui_RGBA, u8(v.nick) .. ' [' .. v.id .. ']')
			end
			if imgui.IsItemClicked() and tonumber(settings.player_info.fraction_rank_number) >= 9 then 
				show_leader_fast_menu(v.id)
				MembersWindow[0] = false
			end
			imgui.SetColumnWidth(-1, 300 * MONET_DPI_SCALE)
			imgui.NextColumn()
			imgui.CenterColumnText(u8(v.rank) .. ' (' .. u8(v.rank_number) .. ')')
			imgui.SetColumnWidth(-1, 230 * MONET_DPI_SCALE)
			imgui.NextColumn()
			imgui.CenterColumnText(u8(v.warns .. '/3'))
			imgui.SetColumnWidth(-1, 75 * MONET_DPI_SCALE)
			imgui.Columns(1)
			imgui.Separator()
		end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return WantedWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 1.2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		if tonumber(#wanted) >= 16 then
			sizeYY = 413
		elseif tonumber(#wanted) > 0 then
			sizeYY = 24.5 * ( tonumber(#wanted) + 2 )
		elseif tonumber(#wanted) == 0 then
			sampAddChatMessage('[Justice Helper] {ffffff}Сейчас на сервере нету игроков с розыском!', message_color)
			WantedWindow[0] = false
		end
		imgui.SetNextWindowSize(imgui.ImVec2(350 * MONET_DPI_SCALE, sizeYY * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		--imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, 413 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		
		imgui.Begin(fa.STAR .. u8" Список преступников (всего " .. #wanted .. u8')', WantedWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize )
		player.HideCursor = true
		imgui.Columns(3)
		imgui.CenterColumnText(u8("Никнейм"))
		imgui.SetColumnWidth(-1, 200 * MONET_DPI_SCALE)
		imgui.NextColumn()
		imgui.CenterColumnText(u8("Розыск"))
		imgui.SetColumnWidth(-1, 65 * MONET_DPI_SCALE)
		imgui.NextColumn()
		imgui.CenterColumnText(u8("Растояние"))
		imgui.SetColumnWidth(-1, 80 * MONET_DPI_SCALE)
		imgui.Columns(1)
		for i, v in ipairs(wanted) do
			imgui.Separator()
			imgui.Columns(3)
			local rgbNormalized = argbToRgbNormalized(sampGetPlayerColor(v.id))  -- Преобразуем ARGB в RGB в диапазоне от 0.00 до 1.00
			local imgui_RGBA = imgui.ImVec4(rgbNormalized[1], rgbNormalized[2], rgbNormalized[3], 1)
			imgui.CenterColumnColorText(imgui_RGBA, u8(v.nick) .. ' [' .. v.id .. ']')
			if imgui.IsItemClicked() and not v.dist:find('В интерьере') then
				sampSendChat('/pursuit ' .. v.id)
			end
			imgui.NextColumn()
			imgui.CenterColumnText(u8(v.lvl) .. ' ' .. fa.STAR)
			imgui.NextColumn()
			imgui.CenterColumnText(u8(v.dist))
			imgui.NextColumn()
			imgui.Columns(1)
			
		end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return NoteWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.FILE_PEN .. ' '.. show_note_name, NoteWindow, imgui.WindowFlags.AlwaysAutoResize )
		imgui.Text(show_note_text:gsub('&','\n'))
		imgui.Separator()
		if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
			NoteWindow[0] = false
		end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return FastMenu[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		--imgui.SetNextWindowSize(imgui.ImVec2(290 * MONET_DPI_SCALE, 415 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.USER .. ' '..sampGetPlayerNickname(player_id)..' ['..player_id.. ']##FastMenu', FastMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize )
		for _, command in ipairs(commands.commands) do
			if command.enable and command.arg == '{arg_id}' and not command.text:find('/cure') and not command.text:find('/unstuff') then
				if imgui.Button(u8(command.description), imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
					sampProcessChatInput("/" .. command.cmd .. " " .. player_id)
					FastMenu[0] = false
				end
			end
		end
		imgui.End()
    end
)

-- local pie = require("imgui_piemenu")
-- FastPieMenu[0] = true
-- imgui.OnFrame(
--     function() return FastPieMenu[0] end,
--     function(player)
-- 		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
-- 		if not isMonetLoader() and not sampIsChatInputActive() then player.HideCursor = true else player.HideCursor = false end
-- 		imgui.Begin('##FastPieMenu', FastPieMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBackground  + imgui.WindowFlags.NoTitleBar )
		
-- 		--if isKeyDown(VK_RBUTTON) then
-- 		if imgui.IsMouseClicked(3) then
-- 			imgui.OpenPopup('PieMenu')
-- 			--player.HideCursor = false
-- 		end

-- 		if pie.BeginPiePopup('PieMenu', 1) then
-- 			player.HideCursor = false
-- 			if pie.PieMenuItem('Test1') then 
			
-- 			end
-- 			if pie.PieMenuItem('Test2') then
			
-- 			end
-- 			if pie.PieMenuItem('Test3', false) then 
-- 				sampSendChat('кхм')
-- 			end
-- 			if pie.BeginPieMenu('Sub') then
-- 			  	if pie.BeginPieMenu('Sub sub\nmenu') then
-- 					if pie.PieMenuItem('SubSub') then
					
-- 					end
-- 					if pie.PieMenuItem('SubSub2') then 
					
-- 					end
-- 					pie.EndPieMenu()
-- 			  	end
-- 				if pie.PieMenuItem('TestSub') then 
				
-- 				end
-- 			 	if pie.PieMenuItem('TestSub2') then 
				
-- 				end
-- 				pie.EndPieMenu()
-- 			end
-- 			pie.EndPiePopup()
-- 		end

-- 		imgui.End()
--     end
-- )

imgui.OnFrame(
    function() return LeaderFastMenu[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.USER..' '..sampGetPlayerNickname(player_id)..' ['..player_id..']##LeaderFastMenu', LeaderFastMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize  )
		for _, command in ipairs(commands.commands_manage) do
			if command.enable and command.arg == '{arg_id}' then
				if imgui.Button(u8(command.description), imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
					sampProcessChatInput("/" .. command.cmd .. " " .. player_id)
					LeaderFastMenu[0] = false
				end
			end
		end
		if not isMonetLoader() then
			if imgui.Button(u8"Выдать выговор",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
				sampSetChatInputEnabled(true)
				sampSetChatInputText('/vig '..player_id..' ')
				LeaderFastMenu[0] = false
			end
			if imgui.Button(u8"Уволить из организации",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
				sampSetChatInputEnabled(true)
				sampSetChatInputText('/uval '..player_id..' ')
				LeaderFastMenu[0] = false
			end
		end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return GiveRankMenu[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.BUILDING_SHIELD.." Justice Helper##rank", GiveRankMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize)
		imgui.CenterText(u8'Выберите ранг для '.. sampGetPlayerNickname(player_id) .. ':')
		imgui.PushItemWidth(250 * MONET_DPI_SCALE)
		imgui.SliderInt('', giverank, 1, 9)
		imgui.Separator()
		if imgui.Button(fa.USER_NURSE .. u8" Выдать ранг" , imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then
			local command_find = false
			for _, command in ipairs(commands.commands_manage) do
				if command.enable and command.text:find('/giverank {arg_id}') then
					command_find = true
					local modifiedText = command.text
					local wait_tag = false
					local arg_id = player_id
					modifiedText = modifiedText:gsub('%{get_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id) or "")
					modifiedText = modifiedText:gsub('%{get_rp_nick%(%{arg_id%}%)%}', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
					modifiedText = modifiedText:gsub('%{get_ru_nick%(%{arg_id%}%)%}', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
					modifiedText = modifiedText:gsub('%{arg_id%}', arg_id or "")
					lua_thread.create(function()
						isActiveCommand = true
						if isMonetLoader() and settings.general.mobile_stop_button then
							sampAddChatMessage('[Justice Helper] {ffffff}Чтобы остановить отыгровку команды используйте ' .. message_color_hex .. '/stop {ffffff}или нажмите кнопку внизу экрана', message_color)
							CommandStopWindow[0] = true
						elseif not isMonetLoader() and hotkey_no_errors and settings.general.bind_command_stop and settings.general.use_binds then
							sampAddChatMessage('[Justice Helper] {ffffff}Чтобы остановить отыгровку команды используйте ' .. message_color_hex .. '/stop {ffffff}или нажмите ' .. message_color_hex .. getNameKeysFrom(settings.general.bind_command_stop), message_color)
						else
							sampAddChatMessage('[Justice Helper] {ffffff}Чтобы остановить отыгровку команды используйте ' .. message_color_hex .. '/stop', message_color)
						end
						local lines = {}
						for line in string.gmatch(modifiedText, "[^&]+") do
							table.insert(lines, line)
						end
						for _, line in ipairs(lines) do 
							if command_stop then 
								command_stop = false 
								isActiveCommand = false
								if isMonetLoader() and settings.general.mobile_stop_button then
									CommandStopWindow[0] = false
								end
								sampAddChatMessage('[Justice Helper] {ffffff}Отыгровка команды /' .. command.cmd .. " успешно остановлена!", message_color) 
								return 
							end
							if wait_tag then
								for tag, replacement in pairs(tagReplacements) do
									local success, result = pcall(string.gsub, line, "{" .. tag .. "}", replacement())
									if success then
										line = result
									end
								end
								sampSendChat(line)
								if debug_mode then sampAddChatMessage('[Justice Helper DEBUG] Отправляю сообщение: ' .. line, message_color) end
								wait(tonumber(command.waiting)*1000)	
							end
							if not wait_tag then
								if line == '{show_rank_menu}' then
									wait_tag = true
								end
							end
						end
						isActiveCommand = false
						if isMonetLoader() and settings.general.mobile_stop_button then
							CommandStopWindow[0] = false
						end
					end)
				end
			end
			if not command_find then
				sampAddChatMessage('[Justice Helper] {ffffff}Бинд для изменения ранга отсутствует либо отключён!', message_color)
				sampAddChatMessage('[Justice Helper] {ffffff}Попробуйте сбросить настройки хелпера!', message_color)
				sampSendChat('/giverank ' .. player_id .. " " .. giverank[0])
			end
			GiveRankMenu[0] = false
		end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return CommandStopWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - 50 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.BUILDING_SHIELD .. " Justice Helper##CommandStopWindow", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize )
		if isMonetLoader() and isActiveCommand then
			if imgui.Button(fa.CIRCLE_STOP..u8' Остановить отыгровку ') then
				command_stop = true 
				CommandStopWindow[0] = false
			end
		else
			CommandStopWindow[0] = false
		end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return CommandPauseWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - 50 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.BUILDING_SHIELD.." Justice Helper##CommandPauseWindow", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize )
		if command_pause then
			if imgui.Button(fa.CIRCLE_ARROW_RIGHT .. u8' Продолжить ', imgui.ImVec2(150 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
				command_pause = false
				CommandPauseWindow[0] = false
			end
			imgui.SameLine()
			if imgui.Button(fa.CIRCLE_XMARK .. u8' Полный STOP ', imgui.ImVec2(150 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
				command_stop = true 
				command_pause = false
				CommandPauseWindow[0] = false
			end
		else
			CommandPauseWindow[0] = false
		end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return FastMenuPlayers[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.BUILDING_SHIELD..u8" Выберите игрока##fast_menu_players", FastMenuPlayers, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize  )
		if tonumber(#get_players()) == 0 then
			show_fast_menu(get_players()[1])
			FastMenuPlayers[0] = false
		elseif tonumber(#get_players()) >= 1 then
			for _, playerId in ipairs(get_players()) do
				local id = tonumber(playerId)
				if imgui.Button(sampGetPlayerNickname(id), imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
					if tonumber(#get_players()) ~= 0 then show_fast_menu(id) end
					FastMenuPlayers[0] = false
				end
			end
		end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return FastMenuButton[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 8.5, sizeY / 2.3), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.HOSPITAL.." Justice Helper##fast_menu_button", FastMenuButton, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar  )
		if imgui.Button(fa.IMAGE_PORTRAIT..u8' Взаимодействие ') then
			if tonumber(#get_players()) == 1 then
				show_fast_menu(get_players()[1])
				FastMenuButton[0] = false
			elseif tonumber(#get_players()) > 1 then
				FastMenuPlayers[0] = true
				FastMenuButton[0] = false
			end
		end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return InformationWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 8, sizeY / 1.7), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(225 * MONET_DPI_SCALE, 113 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.BUILDING_SHIELD .. u8" Justice Helper##info_menu", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize )
		if not isMonetLoader() and not sampIsChatInputActive() then player.HideCursor = true else player.HideCursor = false end
		imgui.Text(fa.CITY .. u8(' Город: ') .. u8(tagReplacements.get_city()))
		imgui.Text(fa.MAP_LOCATION_DOT .. u8(' Район: ') .. u8(tagReplacements.get_area()))
		imgui.Text(fa.LOCATION_CROSSHAIRS .. u8(' Квадрат: ') .. u8(tagReplacements.get_square()))
		imgui.Separator()
		imgui.Text(fa.CLOCK .. u8(' Текущее время: ') .. u8(tagReplacements.get_time()))
		imgui.End()
    end
)

imgui.OnFrame(
    function() return Information1Window[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 8, sizeY / 2.7), imgui.Cond.FirstUseEver, imgui.ImVec2(0.6, 0.6))
		imgui.SetNextWindowSize(imgui.ImVec2(225 * MONET_DPI_SCALE, 113 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.BUILDING_SHIELD .. u8" Justice Helper Keybinds##info_menu", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize )
		if not isMonetLoader() and not sampIsChatInputActive() then player.HideCursor = true else player.HideCursor = false end
		imgui.Text(fa.CIRCLE_INFO .. u8(' /passs - запросить документы '))
		imgui.Text(fa.CIRCLE_INFO .. u8(' /pl - выбросить игрока из транспорта '))
		imgui.Text(fa.CIRCLE_INFO .. u8(' /camon - включить скрытую камеру '))
		imgui.Separator()
		imgui.Text(fa.CIRCLE_INFO .. u8(' /frl - первичный обыск '))
		imgui.Text(fa.CIRCLE_INFO .. u8(' /fr - полный обыск '))
		imgui.End()
    end
)

imgui.OnFrame(
    function() return PatroolMenu[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - 100 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(225 * MONET_DPI_SCALE, 113 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.BUILDING_SHIELD .. u8" Justice Helper##patrool_info_menu", PatroolMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize )
		if not isMonetLoader() and not sampIsChatInputActive() then player.HideCursor = true else player.HideCursor = false end
		if patrool_active then
			imgui.Text(fa.CLOCK .. u8(' Время патрулирования: ') .. u8(tagReplacements.get_patrool_time()))
			imgui.Separator()
			imgui.Text(fa.CIRCLE_INFO .. u8(' Ваше состояние: ') .. u8(tagReplacements.get_patrool_code()))
			imgui.SameLine()
			if imgui.SmallButton(fa.GEAR) then
				imgui.OpenPopup(fa.BUILDING_SHIELD .. u8(' Justice Helper##patrool_select_code'))
			end
			imgui.Separator()
			if imgui.Button(fa.CIRCLE_INFO .. u8(' Доклад'), imgui.ImVec2(100 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
				lua_thread.create(function ()
					sampSendChat('/r ' .. tagReplacements.my_doklad_nick() .. ' на CONTROL. Продолжаю патруль, нахожусь в районе ' .. tagReplacements.get_area() .. " (" .. tagReplacements.get_square() .. ').')
					wait(1200)
					if tagReplacements.get_car_units() ~= 'Нету' then
						sampSendChat('/r Патрулирую уже ' .. format_patrool_time(patrool_time) .. ' в составе юнита ' .. tagReplacements.get_car_units() .. ', состояние ' .. u8(tagReplacements.get_patrool_code()) .. '.')
					else
						sampSendChat('/r Патрулирую уже ' .. format_patrool_time(patrool_time) .. ', состояние ' .. u8(tagReplacements.get_patrool_code()) .. '.')
					end
				end)
			end
			imgui.SameLine()
			if imgui.Button(fa.CIRCLE_STOP .. u8(' Завершить'), imgui.ImVec2(100 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
				lua_thread.create(function ()
					patrool_active = false
					sampSendChat('/r ' .. tagReplacements.my_doklad_nick() .. ' на CONTROL. Завершаю патруль, освобождаю маркировку ' .. tagReplacements.get_patrool_mark() .. ', состояние ' .. tagReplacements.get_patrool_code())
					wait(1200)
					sampSendChat('/r Патрулировал ' .. format_patrool_time(patrool_time), -1)
					patrool_time = 0
					patrool_start_time = 0
					patrool_current_time = 0
					patrool_code = 'CODE4'
					ComboPatroolCode[0] = 5
					PatroolMenu[0] = false
				end)
			end
		else
			if imgui.Button(fa.CIRCLE_PLAY .. u8(' Начать патруль'), imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
				if isCharInAnyCar(PLAYER_PED) then
					imgui.OpenPopup(fa.BUILDING_SHIELD .. u8(' Justice Helper##start_patrool'))
				else
					PatroolMenu[0] = false
					sampAddChatMessage('[Justice Helper] {ffffff}Нельзя начать патруль, вы должны быть за рулём транспорта!', message_color)
				end
			end
		end
		if imgui.BeginPopupModal(fa.BUILDING_SHIELD .. u8(' Justice Helper##start_patrool'), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  ) then
			player.HideCursor = false 
			imgui.CenterText(u8('Настройка данных перед началом патруля:'))
			imgui.Separator()
			imgui.Text(fa.CIRCLE_INFO .. u8(' Ваша маркировка: '))
			imgui.SameLine()
			imgui.PushItemWidth(150 * MONET_DPI_SCALE)
			if imgui.Combo('##patrool_mark', ComboPatroolMark, ImItemsPatroolMark, #combo_patrool_mark_list) then
				patrool_mark = combo_patrool_mark_list[ComboPatroolMark[0] + 1] 
			end
			imgui.Separator()
			imgui.Text(fa.CIRCLE_INFO .. u8(' Ваше состояние: '))
			imgui.SameLine()
			imgui.PushItemWidth(150 * MONET_DPI_SCALE)
			if imgui.Combo('##patrool_code', ComboPatroolCode, ImItemsPatroolCode, #combo_patrool_code_list) then
				patrool_code = combo_patrool_code_list[ComboPatroolCode[0] + 1]
			end
			imgui.Separator()
			imgui.Text(fa.CIRCLE_INFO .. u8(' Напарники: ') .. u8(tagReplacements.get_car_units()))
			imgui.Separator()
			if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(150 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(fa.PLAY .. u8' Начать патруль', imgui.ImVec2(150 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
				patrool_time = 0
				patrool_start_time = os.time()
				patrool_active = true
				lua_thread.create(function ()
					sampSendChat('/r ' .. tagReplacements.my_doklad_nick() .. ' на CONTROL. Начинаю патруль,  нахожусь в районе ' .. tagReplacements.get_area() .. " (" .. tagReplacements.get_square() .. ').')
					wait(1200)
					if tagReplacements.get_car_units() ~= 'Нету' then
						sampSendChat('/r Занимаю маркировку ' .. tagReplacements.get_patrool_mark() .. ', нахожусь в составе юнита ' .. tagReplacements.get_car_units() .. ', состояние ' .. tagReplacements.get_patrool_code() .. '.')
					else
						sampSendChat('/r Занимаю маркировку ' .. tagReplacements.get_patrool_mark() .. ', состояние ' .. tagReplacements.get_patrool_code() .. '.')
					end
				end)
				imgui.CloseCurrentPopup()
			end
			imgui.End()
		end
		if imgui.BeginPopup(fa.BUILDING_SHIELD .. u8(' Justice Helper##patrool_select_code'), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  ) then
			player.HideCursor = false 
			imgui.PushItemWidth(150 * MONET_DPI_SCALE)
			if imgui.Combo('##patrool_code', ComboPatroolCode, ImItemsPatroolCode, #combo_patrool_code_list) then
				patrool_code = combo_patrool_code_list[ComboPatroolCode[0] + 1]
				imgui.CloseCurrentPopup()
			end
			-- imgui.Separator()
			-- if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(150 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
			-- 	imgui.CloseCurrentPopup()
			-- end
			imgui.EndPopup()
		end
		imgui.End()
    end
)

imgui.OnFrame(
    function() return UpdateWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.CIRCLE_INFO .. u8" Оповещение##need_update_helper", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  )
		imgui.CenterText(u8'У вас сейчас установлена версия хелпера ' .. u8(tostring(thisScript().version)) .. ".")
		imgui.CenterText(u8'В базе данных найдена версия хелпера - ' .. u8(updateVer) .. ".")
		imgui.CenterText(u8'Рекомендуется обновиться, дабы иметь весь актуальный функционал!')
		imgui.Separator()
		imgui.CenterText(u8('Что нового в версии ') .. u8(updateVer) .. ':')
		imgui.Text(u8(updateInfoText))
		imgui.Separator()
		if imgui.Button(fa.CIRCLE_XMARK .. u8' Не обновлять ',  imgui.ImVec2(250 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
			UpdateWindow[0] = false
		end
		imgui.SameLine()
		if imgui.Button(fa.DOWNLOAD ..u8' Загрузить новую версию',  imgui.ImVec2(250 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
			download_helper = true
			downloadFileFromUrlToPath(updateUrl, path_helper)
			UpdateWindow[0] = false
		end
		imgui.End()
    end
)








imgui.OnFrame(
    function() return DoprosMenu[0] end,
    function(player)
		if player_id ~= nil and isParamSampID(player_id) then
			imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(fa.PERSON_CIRCLE_CHECK..u8' Проведение допроса игроку ' .. sampGetPlayerNickname(player_id), DoprosMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
			if imgui.BeginChild('dopros1', imgui.ImVec2(240 * MONET_DPI_SCALE, 182 * MONET_DPI_SCALE), true) then
			imgui.CenterColumnText(fa.BOOKMARK .. u8" Основное")
			imgui.Separator()
			if imgui.Button(fa.PLAY .. u8" Начать допрос", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				lua_thread.create(function()
				    sampSendChat("/me включил видеозапись и аудиозапись")
				end)
			end
				if imgui.Button(fa.PASSPORT .. u8" Попросить документы", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				lua_thread.create(function()
					sampSendChat("Хорошо представьтесь, как вас зовут? А также покажите ваши документы для проверки.")
				end)
			end
				if imgui.Button(fa.PASSPORT .. u8" Спросить в каком кармане паспорт", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				lua_thread.create(function()
					sampSendChat("/do В каком кармане паспорт?")
				end)
			end
				if imgui.Button(fa.PASSPORT .. u8" Представиться", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				lua_thread.create(function()
					sampSendChat("Хорошо, я " .. settings.player_info.name_surname .. " - " .. settings.player_info.fraction_rank .. ' ' .. settings.player_info.fraction_tag)
				end)
			end
			if imgui.Button(fa.PASSPORT .. u8" Зачитать правило миранды и разъяснить последствия дачи ложных показаний ", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				lua_thread.create(function()
					find_and_use_command('/mr')
					wait(8000)
					sampSendChat("Также вы имеете право на 1 телефонный зовнок длинною в три минуты.")
				end)
			end
			if imgui.Button(fa.USER .. u8" Вопрос #1", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				sampSendChat("Вы понимаете почему вы здесь?")
			end
			imgui.EndChild()
			end
			imgui.SameLine()
			if imgui.BeginChild('dopros2', imgui.ImVec2(240 * MONET_DPI_SCALE, 182 * MONET_DPI_SCALE), true) then
				imgui.CenterColumnText(fa.BOOKMARK..u8" Дополнительно")
				imgui.Separator()
				if imgui.Button(fa.GLOBE .. u8" Наркотики", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
					sampSendChat("Откуда у вас эти наркотики? Кто вам их дал?")
					wait(2000)
					sampSendChat("Я вас внимательно слушаю.")
                end
				if imgui.Button(fa.CIRCLE_QUESTION .. u8" Наличие опыта работы", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
					sampSendChat("Имеется ли у Вас опыт работы в нашей сфере?")
				end
				if imgui.Button(fa.CIRCLE_QUESTION .. u8" Почему именно мы?", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
					sampSendChat("Скажите почему Вы выбрали именно нас?")
				end
				if imgui.Button(fa.CIRCLE_QUESTION .. u8" Что такое адекватность?", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
					sampSendChat("Скажите что по вашему значит \"Адекватность\"?")
				end
				if imgui.Button(fa.CIRCLE_QUESTION .. u8" Что такое ДМ?", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
					sampSendChat("Скажите как вы думаете, что такое \"ДМ\"?")
				end
			imgui.EndChild()
			end
			imgui.SameLine()
			if imgui.BeginChild('dopros3', imgui.ImVec2(150 * MONET_DPI_SCALE, -1), true) then
				imgui.CenterColumnText(fa.CIRCLE_XMARK .. u8" Отказы")
				imgui.Separator()
				if imgui.Selectable(u8"Нету паспорта") then
					lua_thread.create(function ()
						DoprosMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("У вас нету паспорта.")
						wait(2000)
						sampSendChat("Получите паспорт в паспортном столе на 1 этаже Мэрии.")
					end)
				end
				if imgui.Selectable(u8"Нету мед.карты") then
					lua_thread.create(function ()
						DoprosMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("У вас нету мед.карты, получите её в любой больнице.")
					end)
				end
				if imgui.Selectable(u8"Нету военного билета") then
					lua_thread.create(function ()
						DoprosMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("У вас нету военного билета из армии!")
                        wait(2000)
						sampSendChat("/n Получить его можно отслужив в армии либо купить в /donate ")
					end)
				end
                if imgui.Selectable(u8"Законопослушность") then
					lua_thread.create(function ()
						DoprosMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("У вас плохая законопослушность.")
						wait(2000)
						sampSendChat("/n Необходимо иметь минимум 35 законопослушности!")
					end)
				end
				if imgui.Selectable(u8"Наркозависимость") then
					lua_thread.create(function ()
						DoprosMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("Вы наркозависимый, сначало вам необходимо вылечиться в больнице!")
					end)
				end
				if imgui.Selectable(u8"НонРП ник") then
					lua_thread.create(function ()
						DoprosMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("У вас в паспорте опечатка в имени.")
						wait(2000)
						sampSendChat("/n У вас НонРП ник, измените его!")
					end)
				end	
				if imgui.Selectable(u8"Активная повестка") then
					lua_thread.create(function ()
						DoprosMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("У вас есть повестка, вы не можете устроиться к нам!")
						wait(2000)
						sampSendChat("Вы можете устроиться в МО, либо в больнице пройдите обследование")
					end)
				end
				if imgui.Selectable(u8"Проф.непригодность") then
					lua_thread.create(function ()
						DoprosMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("Вы не подходите для нашей работы по профессиональным качествам.")
					end)
				end
			end
			imgui.EndChild()
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Прозиошла ошибка, ID игрока недействителен!', message_color)
			DoprosMenu[0] = false
		end
    end
)












imgui.OnFrame(
    function() return SobesMenu[0] end,
    function(player)
		if player_id ~= nil and isParamSampID(player_id) then
			imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(fa.PERSON_CIRCLE_CHECK..u8' Проведение собеседования игроку ' .. sampGetPlayerNickname(player_id), SobesMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
			if imgui.BeginChild('sobes1', imgui.ImVec2(240 * MONET_DPI_SCALE, 182 * MONET_DPI_SCALE), true) then
			imgui.CenterColumnText(fa.BOOKMARK .. u8" Основное")
			imgui.Separator()
			if imgui.Button(fa.PLAY .. u8" Начать собеседование", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				lua_thread.create(function()
					sampSendChat("Здравствуйте, я " .. settings.player_info.name_surname .. " - " .. settings.player_info.fraction_rank .. ' ' .. settings.player_info.fraction_tag)
					wait(2000)
					sampSendChat("Вы пришли к нам на собеседование?")
				end)
			end
			if imgui.Button(fa.PASSPORT .. u8" Попросить документы", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				lua_thread.create(function()
					sampSendChat("Хорошо, предоставьте мне все ваши документы для прверки.")
					wait(2000)
					sampSendChat("Мне нужен ваш Паспорт, Мед.карта и Лицензии.")
					wait(2000)
					sampSendChat("/n " .. sampGetPlayerNickname(player_id) .. ", используйте /showpass [ID] , /showmc [ID] , /showlic [ID]")
					wait(2000)
					sampSendChat("/n Обязательно с RP отыгровками!")
				end)
			end
			if imgui.Button(fa.USER .. u8" Расскажите о себе", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				sampSendChat("Немного расскажите о себе.")
			end
			
			if imgui.Button(fa.CHECK .. u8" Собеседование пройдено", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				sampSendChat("/todo Поздравляю! Вы успешно прошли собеседование!*улыбаясь")
			end
			if imgui.Button(fa.USER_PLUS .. u8" Пригласить в организацию", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				find_and_use_command('/invite {arg_id}', player_id)
				SobesMenu[0] = false
			end
			imgui.EndChild()
			end
			imgui.SameLine()
			if imgui.BeginChild('sobes2', imgui.ImVec2(240 * MONET_DPI_SCALE, 182 * MONET_DPI_SCALE), true) then
				imgui.CenterColumnText(fa.BOOKMARK..u8" Дополнительно")
				imgui.Separator()
				if imgui.Button(fa.GLOBE .. u8" Наличие спец.рации Discord", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
					sampSendChat("Имеется ли у Вас спец. рация Discord?")
				end
				if imgui.Button(fa.CIRCLE_QUESTION .. u8" Наличие опыта работы", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
					sampSendChat("Имеется ли у Вас опыт работы в нашей сфере?")
				end
				if imgui.Button(fa.CIRCLE_QUESTION .. u8" Почему именно мы?", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
					sampSendChat("Скажите почему Вы выбрали именно нас?")
				end
				if imgui.Button(fa.CIRCLE_QUESTION .. u8" Что такое адекватность?", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
					sampSendChat("Скажите что по вашему значит \"Адекватность\"?")
				end
				if imgui.Button(fa.CIRCLE_QUESTION .. u8" Что такое ДМ?", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
					sampSendChat("Скажите как вы думаете, что такое \"ДМ\"?")
				end
			imgui.EndChild()
			end
			imgui.SameLine()
			if imgui.BeginChild('sobes3', imgui.ImVec2(150 * MONET_DPI_SCALE, -1), true) then
				imgui.CenterColumnText(fa.CIRCLE_XMARK .. u8" Отказы")
				imgui.Separator()
				if imgui.Selectable(u8"Нету паспорта") then
					lua_thread.create(function ()
						SobesMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("У вас нету паспорта.")
						wait(2000)
						sampSendChat("Получите паспорт в паспортном столе на 1 этаже Мэрии.")
					end)
				end
				if imgui.Selectable(u8"Нету мед.карты") then
					lua_thread.create(function ()
						SobesMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("У вас нету мед.карты, получите её в любой больнице.")
					end)
				end
				if imgui.Selectable(u8"Нету военного билета") then
					lua_thread.create(function ()
						SobesMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("У вас нету военного билета из армии!")
                        wait(2000)
						sampSendChat("/n Получить его можно отслужив в армии либо купить в /donate ")
					end)
				end
                if imgui.Selectable(u8"Законопослушность") then
					lua_thread.create(function ()
						SobesMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("У вас плохая законопослушность.")
						wait(2000)
						sampSendChat("/n Необходимо иметь минимум 35 законопослушности!")
					end)
				end
				if imgui.Selectable(u8"Наркозависимость") then
					lua_thread.create(function ()
						SobesMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("Вы наркозависимый, сначало вам необходимо вылечиться в больнице!")
					end)
				end
				if imgui.Selectable(u8"НонРП ник") then
					lua_thread.create(function ()
						SobesMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("У вас в паспорте опечатка в имени.")
						wait(2000)
						sampSendChat("/n У вас НонРП ник, измените его!")
					end)
				end	
				if imgui.Selectable(u8"Активная повестка") then
					lua_thread.create(function ()
						SobesMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("У вас есть повестка, вы не можете устроиться к нам!")
						wait(2000)
						sampSendChat("Вы можете устроиться в МО, либо в больнице пройдите обследование")
					end)
				end
				if imgui.Selectable(u8"Проф.непригодность") then
					lua_thread.create(function ()
						SobesMenu[0] = false
						sampSendChat("/todo К сожалению, вы нам не подходите*с разочарованием на лице")
						wait(2000)
						sampSendChat("Вы не подходите для нашей работы по профессиональным качествам.")
					end)
				end
			end
			imgui.EndChild()
		else
			sampAddChatMessage('[Justice Helper] {ffffff}Прозиошла ошибка, ID игрока недействителен!', message_color)
			SobesMenu[0] = false
		end
    end
)

imgui.OnFrame(
    function() return SumMenuWindow[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, 413 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
        imgui.Begin(fa.STAR .. u8" Умная выдача розыска##sum_menu", SumMenuWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
        if smart_uk ~= nil and isParamSampID(player_id) then
			imgui.SetWindowFontScale(1.4)
			imgui.Text(fa.MAGNIFYING_GLASS .. u8' Поиск:')
			imgui.SetWindowFontScale(1.0)
			imgui.SameLine()
			imgui.PushItemWidth(467 * MONET_DPI_SCALE)
			imgui.InputText(u8'##input_sum', input_sum, 128) 
			imgui.SameLine()
			if imgui.Button(fa.GEAR) then
				imgui.OpenPopup(fa.STAR .. u8(' Настройка выдачи розыска'))
			end
			if imgui.BeginPopupModal(fa.STAR .. u8(' Настройка выдачи розыска'), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  ) then
				if imgui.Checkbox(u8' Запрашивать выдачу розыска в /r (если ваш ранг недостаточен)', checkbox_sum) then
					settings.general.use_form_su = checkbox_sum[0]
					save_settings()
				end
				if imgui.Button(fa.CIRCLE_XMARK .. u8(' Закрыть'), imgui.ImVec2(imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end
			imgui.Separator()
			if u8:decode(ffi.string(input_sum)) == '' then
				for _, chapter in ipairs(smart_uk) do
					if imgui.CollapsingHeader(u8(chapter.name)) then
						if chapter.item then 
							for _, item in ipairs(chapter.item) do
								local popup_id = fa.TRIANGLE_EXCLAMATION .. u8' Перепроверьте данные перед выдачей розыска##' .. item.text .. item.lvl .. item.reason
								-- imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.00, 1.00, 1.00, 0.65))
								if imgui.Button(u8(item.text)..'##' .. item.text .. item.lvl .. item.reason, imgui.ImVec2( imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
									imgui.OpenPopup(popup_id)
								end 
								-- imgui.PopStyleColor()
								if imgui.BeginPopupModal(popup_id, nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
									imgui.Text(fa.USER .. u8' Игрок: ' .. u8(sampGetPlayerNickname(player_id)) .. ' [' .. player_id .. ']')
									imgui.Text(fa.STAR .. u8' Уровень розыска: ' .. item.lvl)
									imgui.Text(fa.COMMENT .. u8' Причина выдачи розыска: ' .. u8(item.reason))
									imgui.Separator()
									if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
										imgui.CloseCurrentPopup()
									end
									imgui.SameLine()
									if imgui.Button(fa.STAR .. u8' Выдать розыск', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
										SumMenuWindow[0] = false
										if settings.general.use_form_su then
											find_and_use_command('Прошу обьявить в розыск %{arg2%} степени дело N', player_id .. ' ' .. item.lvl .. ' ' .. item.reason)
										else
											find_and_use_command('/su {arg_id} {arg2} {arg3}', player_id .. ' ' .. item.lvl .. ' ' .. item.reason)
										end
										imgui.CloseCurrentPopup()
									end
									imgui.EndPopup()
								end
							end
						end
					end
				end
			else
				local input_sum_decoded = u8:decode(ffi.string(input_sum))
				for _, chapter in ipairs(smart_uk) do
					if chapter.name:rupper():find(input_sum_decoded:rupper()) then
						if imgui.CollapsingHeader(u8(chapter.name)) then
							if chapter.item then 
								for _, item in ipairs(chapter.item) do
									local popup_id = fa.TRIANGLE_EXCLAMATION .. u8' Перепроверьте данные перед выдачей розыска##' .. item.text .. item.lvl .. item.reason
									-- imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.00, 1.00, 1.00, 0.65))
									if imgui.Button(u8(item.text)..'##' .. item.text .. item.lvl .. item.reason, imgui.ImVec2( imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
										imgui.OpenPopup(popup_id)
									end 
									-- imgui.PopStyleColor()
									if imgui.BeginPopupModal(popup_id, nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
										imgui.Text(fa.USER .. u8' Игрок: ' .. u8(sampGetPlayerNickname(player_id)) .. ' [' .. player_id .. ']')
										imgui.Text(fa.STAR .. u8' Уровень розыска: ' .. item.lvl)
										imgui.Text(fa.COMMENT .. u8' Причина выдачи розыска: ' .. u8(item.reason))
										imgui.Separator()
										if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
											imgui.CloseCurrentPopup()
										end
										imgui.SameLine()
										if imgui.Button(fa.STAR .. u8' Выдать розыск', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
											SumMenuWindow[0] = false
											if settings.general.use_form_su then
												find_and_use_command('Прошу обьявить в розыск %{arg2%} степени дело N%(%{arg_id%}%)%. Причина%: %{arg3%}', player_id .. ' ' .. item.lvl .. ' ' .. item.reason)
											else
												find_and_use_command('/su {arg_id} {arg2} {arg3}', player_id .. ' ' .. item.lvl .. ' ' .. item.reason)
											end
											imgui.CloseCurrentPopup()
										end
										imgui.EndPopup()
									end
								end
							end
						end
					end
				end
			end
        else
            sampAddChatMessage('[Justice Helper] {ffffff}Произошла ошибка умного розыска (нету данных либо игрок офнулся)!', message_color)
            SumMenuWindow[0] = false
        end
        imgui.End()
    end
)

imgui.OnFrame(
    function() return TsmMenuWindow[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, 413 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
        imgui.Begin(fa.TICKET .. u8" Умная выдача штрафов##tsm_menu", TsmMenuWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
        if smart_pdd ~= nil and isParamSampID(player_id) then
			imgui.SetWindowFontScale(1.4)
			imgui.Text(fa.MAGNIFYING_GLASS .. u8' Поиск:')
			imgui.SetWindowFontScale(1.0)
			imgui.SameLine()
			imgui.PushItemWidth(495 * MONET_DPI_SCALE)
			imgui.InputText(u8'##input_tsm', input_tsm, 128) 
			imgui.Separator()
			if u8:decode(ffi.string(input_tsm)) == '' then
				for _, chapter in ipairs(smart_pdd) do
					if imgui.CollapsingHeader(u8(chapter.name)) then
						if chapter.item then 
							for _, item in ipairs(chapter.item) do
								local popup_id = fa.TRIANGLE_EXCLAMATION .. u8' Перепроверьте данные перед выдачей штрафа##' .. item.text .. item.amount .. item.reason
								-- imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.00, 1.00, 1.00, 0.65))
								if imgui.Button(u8(item.text)..'##' .. item.text .. item.amount .. item.reason, imgui.ImVec2( imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
									imgui.OpenPopup(popup_id)
								end 
								-- imgui.PopStyleColor()
								if imgui.BeginPopupModal(popup_id, nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
									imgui.Text(fa.USER .. u8' Игрок: ' .. u8(sampGetPlayerNickname(player_id)) .. ' [' .. player_id .. ']')
									imgui.Text(fa.MONEY_CHECK_DOLLAR .. u8' Сумма штрафа: $' .. item.amount)
									imgui.Text(fa.COMMENT .. u8' Причина выдачи штрафа: ' .. u8(item.reason))
									imgui.Separator()
									if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
										imgui.CloseCurrentPopup()
									end
									imgui.SameLine()
									if imgui.Button(fa.TICKET .. u8' Выписать штраф', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
										TsmMenuWindow[0] = false
										find_and_use_command('/writeticket {arg_id}', player_id .. ' ' .. item.amount .. ' ' .. item.reason)
										imgui.CloseCurrentPopup()
									end
									imgui.EndPopup()
								end
							end
						end
					end
				end
			else
				local input_tsm_decoded = u8:decode(ffi.string(input_tsm))
				for _, chapter in ipairs(smart_pdd) do
					if chapter.name:rupper():find(input_tsm_decoded:rupper()) then
						if imgui.CollapsingHeader(u8(chapter.name)) then
							if chapter.item then 
								for _, item in ipairs(chapter.item) do
									local popup_id = fa.TRIANGLE_EXCLAMATION .. u8' Перепроверьте данные перед выдачей штрафа##' .. item.text .. item.amount .. item.reason
									-- imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.00, 1.00, 1.00, 0.65))
									if imgui.Button(u8(item.text)..'##' .. item.text .. item.amount .. item.reason, imgui.ImVec2( imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
										imgui.OpenPopup(popup_id)
									end 
									-- imgui.PopStyleColor()
									if imgui.BeginPopupModal(popup_id, nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
										imgui.Text(fa.USER .. u8' Игрок: ' .. u8(sampGetPlayerNickname(player_id)) .. ' [' .. player_id .. ']')
										imgui.Text(fa.MONEY_CHECK_DOLLAR .. u8' Сумма штрафа: $' .. item.amount)
										imgui.Text(fa.COMMENT .. u8' Причина выдачи штрафа: ' .. u8(item.reason))
										imgui.Separator()
										if imgui.Button(fa.CIRCLE_XMARK .. u8' Отмена', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
											imgui.CloseCurrentPopup()
										end
										imgui.SameLine()
										if imgui.Button(fa.TICKET .. u8' Выписать штраф', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
											TsmMenuWindow[0] = false
											find_and_use_command('/writeticket {arg_id}', player_id .. ' ' .. item.amount .. ' ' .. item.reason)
											imgui.CloseCurrentPopup()
										end
										imgui.EndPopup()
									end
								end
							end
						end
					end
				end
			end
        else
            sampAddChatMessage('[Justice Helper] {ffffff}Произошла ошибка умных штрафов (нету данных либо игрок офнулся)!', message_color)
            TsmMenuWindow[0] = false
        end
        imgui.End()
    end
)

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
function imgui.CenterTextDisabled(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.TextDisabled(text)
end
function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end
function imgui.CenterColumnTextDisabled(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.TextDisabled(text)
end
function imgui.CenterColumnColorText(imgui_RGBA, text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	imgui.TextColored(imgui_RGBA, text)
end
function imgui.CenterButton(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
	if imgui.Button(text) then
		return true
	else
		return false
	end
end
function imgui.CenterColumnButton(text)
	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
    if imgui.Button(text) then
		return true
	else
		return false
	end
end
function imgui.CenterColumnSmallButton(text)
	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
    if imgui.SmallButton(text) then
		return true
	else
		return false
	end
end
function imgui.GetMiddleButtonX(count)
    local width = imgui.GetWindowContentRegionWidth() 
    local space = imgui.GetStyle().ItemSpacing.x
    return count == 1 and width or width/count - ((space * (count-1)) / count)
end
function apply_dark_theme()
	imgui.SwitchContext()
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 * MONET_DPI_SCALE, 2 * MONET_DPI_SCALE)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().GrabMinSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().WindowBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().ChildBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().PopupBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().FrameBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().TabBorderSize = 1 * MONET_DPI_SCALE
	imgui.GetStyle().WindowRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ChildRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().FrameRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().PopupRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ScrollbarRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().GrabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().TabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.12, 0.12, 0.12, 0.95)
end
function apply_moonmonet_theme()
	local generated_color = moon_monet.buildColors(settings.general.moonmonet_theme_color, 1.0, true)
	imgui.SwitchContext()
	imgui.GetStyle().WindowPadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 * MONET_DPI_SCALE, 2 * MONET_DPI_SCALE)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().GrabMinSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().WindowBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().ChildBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().PopupBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().FrameBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().TabBorderSize = 1 * MONET_DPI_SCALE
	imgui.GetStyle().WindowRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ChildRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().FrameRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().PopupRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ScrollbarRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().GrabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().TabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
	imgui.GetStyle().Colors[imgui.Col.Text] = ColorAccentsAdapter(generated_color.accent2.color_50):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TextDisabled] = ColorAccentsAdapter(generated_color.neutral1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.WindowBg] = ColorAccentsAdapter(generated_color.accent2.color_900):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ChildBg] = ColorAccentsAdapter(generated_color.accent2.color_800):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.PopupBg] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.Border] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.Separator] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
	imgui.GetStyle().Colors[imgui.Col.FrameBg] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x60):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.FrameBgHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x70):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.FrameBgActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x50):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TitleBg] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0x7f):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TitleBgActive] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.MenuBarBg] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x91):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0,0,0,0)
	imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x85):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.CheckMark] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.SliderGrab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.SliderGrabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x80):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.Button] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ButtonHovered] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xb3):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ButtonActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.Tab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TabActive] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xb3):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TabHovered] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xb3):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.Header] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.HeaderHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.HeaderActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ResizeGrip] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ResizeGripActive] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xb3):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.PlotLines] = ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.PlotHistogram] = ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.TextSelectedBg] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0x99):as_vec4()
end
function argbToHexWithoutAlpha(alpha, red, green, blue)
    return string.format("%02X%02X%02X", red, green, blue)
end
function rgba_to_argb(rgba_color)
    -- Получаем компоненты цвета
    local r = bit32.band(bit32.rshift(rgba_color, 24), 0xFF)
    local g = bit32.band(bit32.rshift(rgba_color, 16), 0xFF)
    local b = bit32.band(bit32.rshift(rgba_color, 8), 0xFF)
    local a = bit32.band(rgba_color, 0xFF)
    
    -- Собираем ARGB цвет
    local argb_color = bit32.bor(bit32.lshift(a, 24), bit32.lshift(r, 16), bit32.lshift(g, 8), b)
    
    return argb_color
end
function join_argb(a, r, g, b)
    local argb = b 
    argb = bit.bor(argb, bit.lshift(g, 8))
    argb = bit.bor(argb, bit.lshift(r, 16))    
    argb = bit.bor(argb, bit.lshift(a, 24))
    return argb
end
function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end
function ARGBtoRGB(color) 
	return bit.band(color, 0xFFFFFF) 
end
function rgb2hex(r, g, b)
    local hex = string.format("#%02X%02X%02X", r, g, b)
    return hex
end
function ColorAccentsAdapter(color)
    local a, r, g, b = explode_argb(color)
    local ret = {a = a, r = r, g = g, b = b}
    function ret:apply_alpha(alpha)
        self.a = alpha
        return self
    end
    function ret:as_u32()
        return join_argb(self.a, self.b, self.g, self.r)
    end
    function ret:as_vec4()
        return imgui.ImVec4(self.r / 255, self.g / 255, self.b / 255, self.a / 255)
    end
    function ret:as_argb()
        return join_argb(self.a, self.r, self.g, self.b)
    end
    function ret:as_rgba()
        return join_argb(self.r, self.g, self.b, self.a)
    end
    function ret:as_chat()
        return string.format("%06X", ARGBtoRGB(join_argb(self.a, self.r, self.g, self.b)))
    end  
    return ret
end

function main()

	if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end 

	welcome_message()
	initialize_commands()
	if settings.player_info.name_surname == '' or settings.player_info.fraction == 'Неизвестно' then
		sampAddChatMessage('[Justice Helper] {ffffff}Пытаюсь получить ваш /stats поскольку остуствуют данные про вас!', message_color)
		check_stats = true
		sampSendChat('/stats')
	end
	if settings.general.use_info_menu then
		InformationWindow[0] = true
		Information1Window[0] = true
	end	
	check_update()

	while true do
		wait(0)

		if patrool_active then
			patrool_time = os.difftime(os.time(), patrool_start_time)
			if settings.general.auto_doklad_patrool and patrool_time % 600 == 0 then
				sampSendChat('/r ' .. tagReplacements.my_doklad_nick() .. ' на CONTROL. Продолжаю патруль, нахожусь в районе ' .. tagReplacements.get_area() .. " (" .. tagReplacements.get_square() .. ').')
				wait(1200)
				if tagReplacements.get_car_units() ~= 'Нету' then
					sampSendChat('/r Патрулирую уже ' .. format_patrool_time(patrool_time) .. ' в составе юнита ' .. tagReplacements.get_car_units() .. ', состояние ' .. u8(tagReplacements.get_patrool_code()) .. '.')
				else
					sampSendChat('/r Патрулирую уже ' .. format_patrool_time(patrool_time) .. ', состояние ' .. u8(tagReplacements.get_patrool_code()) .. '.')
				end
			end
		end	
		
		if isMonetLoader() then
			if settings.general.mobile_fastmenu_button then
				if tonumber(#get_players()) > 0 and not FastMenu[0] and not FastMenuPlayers[0] then
					FastMenuButton[0] = true
				else
					FastMenuButton[0] = false
				end
			end
		end 

		if clicked and settings.general.auto_clicker_situation then
			if isMonetLoader() then
				local bs = raknetNewBitStream()
				raknetBitStreamWriteInt8(bs, 220)
				raknetBitStreamWriteInt8(bs, 63)
				raknetBitStreamWriteInt8(bs, 25)
				raknetBitStreamWriteInt32(bs, 0)
				raknetBitStreamWriteInt8(bs, 255)
				raknetBitStreamWriteInt8(bs, 255)
				raknetBitStreamWriteInt8(bs, 255)
				raknetBitStreamWriteInt8(bs, 255)
				raknetBitStreamWriteInt32(bs, 0)
				raknetSendBitStream(bs)
				raknetDeleteBitStream(bs)
				wait(10)
			else
				local cmd = "clickMinigame"
				local bs = raknetNewBitStream()
				raknetBitStreamWriteInt8(bs, 220)
				raknetBitStreamWriteInt8(bs, 18)
				raknetBitStreamWriteInt8(bs, #cmd)
				raknetBitStreamWriteInt8(bs, 0)
				raknetBitStreamWriteInt8(bs, 0)
				raknetBitStreamWriteInt8(bs, 0)
				raknetBitStreamWriteString(bs, cmd)
				raknetBitStreamWriteInt32(bs, 0)
				raknetBitStreamWriteInt8(bs, 0)
				raknetBitStreamWriteInt8(bs, 0)
				raknetSendBitStreamEx(bs, 1, 7, 1)
				raknetDeleteBitStream(bs)
				setGameKeyState(1, 255)
				wait(10)
				setGameKeyState(1, 0)
			end
		end

		if nowGun ~= getCurrentCharWeapon(PLAYER_PED) and settings.general.rp_gun then
			oldGun = nowGun
			nowGun = getCurrentCharWeapon(PLAYER_PED)
			if oldGun == 0 then
				sampSendChat("/me " .. gunOn[nowGun] .. " " .. weapons.get_name(nowGun) .. " " .. gunPartOn[nowGun])
			elseif nowGun == 0 then
				sampSendChat("/me " .. gunOff[oldGun] .. " " .. weapons.get_name(oldGun) .. " " .. gunPartOff[oldGun])
			else
				sampSendChat("/me " .. gunOff[oldGun] .. " " .. weapons.get_name(oldGun) .. " " .. gunPartOff[oldGun] .. ", после чего " .. gunOn[nowGun] .. " " .. weapons.get_name(nowGun) .. " " .. gunPartOn[nowGun])
			end
		end

		if WantedWindow[0] and not update_wanted_check and settings.general.auto_update_wanteds then -- обновление вантеда по кд в менюшке
			update_wanted_check = true	
			wanted_new = {}
			check_wanted = true
			for i = 7, 1, -1 do
				sampSendChat('/wanted ' .. i)
				wait(300)
			end
			wanted = wanted_new
			check_wanted = false
			update_wanted_check = false
		end

		if MembersWindow[0] and not update_members_check and settings.general.auto_update_members then -- обновление мемберса в менюшке
			update_members_check = true
			wait(1500)
			if MembersWindow[0] then
				members_new = {} 
				members_check = true 
				sampSendChat("/members") 
			end
			wait(1500)
			update_members_check = false
		end
		
		if settings.general.auto_notify_payday and ((os.date("%M", os.time()) == "55" and os.date("%S", os.time()) == "00") or (os.date("%M", os.time()) == "25" and os.date("%S", os.time()) == "00")) then
			sampAddChatMessage('[Justice Helper] {ffffff}Через 5 минут будет PAYDAY. Наденьте форму чтобы не пропустить зарплату!', message_color)
			wait(1000)
		end

		if settings.general.auto_notify_port and (os.date("%H", os.time()) == "19"  and os.date("%M", os.time()) == "25" and os.date("%S", os.time()) == "00") then
			sampAddChatMessage('[Justice Helper] {ffffff}Через 5 минут будет МП "Порт". Чтобы отметить Порт используйте команду /port', message_color)
			wait(1000)
		end
		
		if isCharInAnyCar(PLAYER_PED) and settings.general.auto_change_code_siren then
			local currentSirenState = isCarSirenOn(storeCarCharIsInNoSave(PLAYER_PED))
			if firstCheck then
				lastSirenState = currentSirenState
				firstCheck = false
			end
			if currentSirenState ~= lastSirenState then
				lastSirenState = currentSirenState
				if currentSirenState then
					sampAddChatMessage("[Justice Helper] {ffffff}В вашем т/с была включена сирена, изменяю ситуационный код на CODE 3!", message_color)
					ComboPatroolCode[0] = 4
					patrool_code = combo_patrool_code_list[ComboPatroolCode[0] + 1]
				else
					sampAddChatMessage("[Justice Helper] {ffffff}В вашем т/с была отключена сирена, изменяю ситуационный код на CODE 4.", message_color)
					ComboPatroolCode[0] = 5
					patrool_code = combo_patrool_code_list[ComboPatroolCode[0] + 1]
				end
			end
		end

	end

end

function onScriptTerminate(script, game_quit)
    if script == thisScript() and not game_quit and not reload_script then
		sampAddChatMessage('[Justice Helper] {ffffff}Произошла неизвестная ошибка, хелпер приостановил свою работу!', message_color)
		if not isMonetLoader() then 
			sampAddChatMessage('[Justice Helper] {ffffff}Используйте ' .. message_color_hex .. 'CTRL {ffffff}+ ' .. message_color_hex .. 'R {ffffff}чтобы перезапустить хелпер.', message_color)
		end
		setInfraredVision(false)
		setNightVision(false)
		play_error_sound()
    end
end
