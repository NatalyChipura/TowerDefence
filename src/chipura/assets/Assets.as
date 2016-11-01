package chipura.assets 
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import movieClip.GnomeDown;
	import movieClip.OrkDown;
	import movieClip.OrkDownLeft;
	import movieClip.OrkLeft;
	import movieClip.OrkTop;
	import movieClip.OrkTopLeft;
	import movieClip.Tower1;
	import movieClip.Tower2;
	import movieClip.Tower3;
	
	import chipura.map.Cell;
	
	import movieClip.GnomeDLeft;
	import movieClip.GnomeLeft;
	import movieClip.GnomeTLeft;
	import movieClip.GnomeTop;
	/**
	 * Класс набор констант и ресурсов
	 * @author Nataly Chipura
	 */
	public class Assets 
	{
		/**
		 * путь к данным уровня
		 */
		static public const PATH_XML_LEVEL:String = "../assets/xml/map/level0.xml";
		/**
		 * путь к данным волны уровня
		 */
		static public const PATH_XML_WAVE:String = "../assets/xml/wave/waveL0.xml";
		
		/**
		 * Изображение карты уровня
		 */
		[Embed (source = "../../../assets/img/map/level0.png")]
        static private const FonMap:Class;
        static public const mapBitmap:Bitmap = new FonMap;
		
		/**
		 * Размер тайла
		 */
		static private var sizeTail:uint;
		
		/**
		 * Количество кадров в секунду
		 */
		static public const FRAME_RATE:uint = 30;
		
		/**
		 * Стартовые деньги
		 */
		static public const COINS_DEFAULT_CNT:uint = 1000;
		
		/////////////////////// CREEPs - ВРАГИ /////////////////////////////////
		
		/**
		 * Дистанция между врагами по умолчанию
		 */
		static public const ENEMY_DISTANCE:uint = 2;
		/**
		 * Тип врага - ГНОМ
		 */
		static public const CREEP_TYPE_GNOME:String = "Gnome";
		/**
		 * Тип врага - ОРК
		 */
		static public const CREEP_TYPE_ORK:String = "Ork";
		
		/////////////////////// TOWERs - БАШНИ ////////////////////////////////
		
		/**
		 * Размер башни в тайлах
		 */
		static public const TOWER_SIZE:uint = 4;
		/**
		 * Расстояние между дорогой и соседними башнями в тайлах
		 */
		static public const TOWER_DISTANCE:uint = 1;
		/**
		 * Тип башни - Стрелок
		 */
		static public const TOWER_TYPE_SHOOTER:String = "TypeTowerShooter";
		/**
		 * Тип башни - Стрелок по всем
		 */
		static public const TOWER_TYPE_SHOOTERALL:String = "TypeTowerShooterAll";
		/**
		 * Тип башни - Замедлитель
		 */
		static public const TOWER_TYPE_FREEZER:String = "TypeTowerFreezer";
		
		/**
		 * Спрайт башни - Стрелок
		 */
		static public const TOWER_SPRITE_SHOOTER:Sprite = new Tower1();
		/**
		 * Спрайт башни - Стрелок по всем
		 */
		static public const TOWER_SPRITE_SHOOTERALL:Sprite = new Tower2();
		/**
		 * Спрайт башни - Замедлитель
		 */
		static public const TOWER_SPRITE_FREEZER:Sprite = new Tower3();

		/**
		 * Тип атаки - Атакует одного, ближайшего к выходу
		 */
		static public const TOWER_ATTACK_ONE:String = "AttackOneEnemy";
		/**
		 * Тип атаки - Атакует всех в поле действия башни
		 */
		static public const TOWER_ATTACK_ALL:String = "AttackAllEnemy";
		
		/**
		 * Цена башни - Стрелок
		 */
		static public const TOWER_PRICE_SHOOTER:uint = 100;
		/**
		 * Цена башни - Стрелок по всем
		 */
		static public const TOWER_PRICE_SHOOTERALL:uint = 85;
		/**
		 * Цена башни - Замедлитель
		 */
		static public const TOWER_PRICE_FREEZER:uint = 50;
		
		/////////////////////// EFFECTs - ЭФФЕКТЫ ////////////////////////////////
		
		static public const EFFECT_TYPE_NONE:String = "EffectNone";
		static public const EFFECT_TYPE_FREEZE:String = "EffectFreeze";
		
		/////////////////////// EVENTs - СОБЫТИЯ /////////////////////////////////
		
		static public const EVENT_LEVEL_LOAD:String = "Evt_LevelLoadComplete";
		
		static public const EVENT_PANEL_TOWER_SELECT:String = "Evt_SelectTowerForAdd";
		static public const EVENT_PANEL_TOWER_MOVE:String = "Evt_TowerMove";
		static public const EVENT_PANEL_TOWER_DROP:String = "Evt_TowerDrop";
		
		static public const EVENT_CREEP_ADD:String = "Evt_NewCreepAdd";
		static public const EVENT_CREEP_DIE:String = "Evt_CreepDie";
		static public const EVENT_CREEP_FINISH:String = "Evt_CreepFinish";
		
		static public const EVENT_WAVE_LOAD:String = "Evt_WaveLoadComplete";
		static public const EVENT_WAVE_NEW:String = "Evt_WaveNew";
		static public const EVENT_WAVE_COMPLETE:String = "Evt_WaveComplete";
		
		
		/////////////////////// COUESE - НАПРАВЛЕНИЯ /////////////////////////////////
		
		static public const COURSE_TOP:Point = new Point(-1, -1);
		static public const COURSE_TOP_RIGHT:Point = new Point(0, -1);
		static public const COURSE_RIGHT:Point = new Point(1, -1);
		static public const COURSE_DOWN_RIGHT:Point = new Point(1, 0);
		static public const COURSE_DOWN:Point = new Point(1, 1);
		static public const COURSE_DOWN_LEFT:Point = new Point(0, 1);
		static public const COURSE_LEFT:Point = new Point(-1, 1);
		static public const COURSE_TOP_LEFT:Point = new Point(-1, 0);

		/**
		 * Набор MovieClip-ов для гномов 
		 */
		static public var gnomeMC:Function = function ( ) : Dictionary { 
			var d:Dictionary = new Dictionary(); 
			d[COURSE_TOP] = new GnomeTop();
			
			d[COURSE_LEFT] = new GnomeLeft();
			var mc:MovieClip = new GnomeLeft();
			mc.scaleX = -1;
			d[COURSE_RIGHT] = mc;
			
			d[COURSE_DOWN_LEFT] = new GnomeDLeft();
			mc = new GnomeDLeft();
			mc.scaleX = -1;
			d[COURSE_DOWN_RIGHT] = mc;
			
			d[COURSE_TOP_LEFT] = new GnomeTLeft();
			mc =  new GnomeTLeft();
			mc.scaleX = -1;
			d[COURSE_TOP_RIGHT] = mc;
			
			d[COURSE_DOWN] = new GnomeDown();
			
			return d;
		}
		
		/**
		 * Набор MovieClip-ов для орков 
		 */
		static public var orkMC:Function = function ( ) : Dictionary { 
			var d:Dictionary = new Dictionary(); 
			d[COURSE_TOP] = new OrkTop();
			
			d[COURSE_LEFT] = new OrkLeft();
			var mc:MovieClip = new OrkLeft();
			mc.scaleX = -1;
			d[COURSE_RIGHT] = mc;
			
			d[COURSE_DOWN_LEFT] = new OrkDownLeft();
			mc = new OrkDownLeft();
			mc.scaleX = -1;
			d[COURSE_DOWN_RIGHT] = mc;
			
			d[COURSE_TOP_LEFT] = new OrkTopLeft();
			mc =  new OrkTopLeft();
			mc.scaleX = -1;
			d[COURSE_TOP_RIGHT] = mc;
			
			d[COURSE_DOWN] = new OrkDown();
			
			return d;
		}
		
	}

}