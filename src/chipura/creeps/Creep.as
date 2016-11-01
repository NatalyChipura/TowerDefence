package chipura.creeps 
{
	import as3isolib.display.IsoSprite;
	import as3isolib.geom.Pt;
	import chipura.creeps.CreepPoint;
	import chipura.Game;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import chipura.assets.Assets;
	import chipura.map.Grid;
	import chipura.map.Cell;
	
	/**
	 * Родительский класс нападающих
	 * @author Nataly Chipura
	 */
	public class Creep extends IsoSprite
	{
		protected var _health:int = 10; 		// здоровье
		
		protected var _pace:Number = 1; 			// темп или шаг перемещения (1 тайл в сек)
		protected var _speed:uint; 				// скорость перемещения (количество пикселей в кадр)
		
		protected var _bonus:uint;				
		
		protected var _indPos:uint = 0; 			// позиция в массиве пути
		
		protected var _creepPoint:CreepPoint; 	// ссылка на точку входа, к которой он принадлежит
		
		private var _cntFrameOnTail:uint;       // количество кадров для прохождения одного тайла
		private var numFrame:uint = 0;			// счетчик кадров
		
		private var txtHealth:TextField = new TextField();
		private var txtFormat:TextFormat;

		protected var _course:Point = Assets.COURSE_TOP; // направление
		
		/**
		 * наложенный эффект
		 */
		protected var _havingEffect:String = Assets.EFFECT_TYPE_NONE;
		
		/**
		 * набор movieClip-ов для анимации направлений движения
		 */
		protected var movieClips:Dictionary;
		
		public function Creep(ePoint:CreepPoint, vHealth:uint, vPace:uint, vBonus:uint) 
		{
			usePreciseValues = true;
			
			txtHealth.y = -3*Grid.sizeTail;
			txtHealth.x = -Grid.sizeTail / 2;
			txtFormat = new TextFormat(); 
			txtFormat.color = 0xFFFFFF; 
			
			_creepPoint = ePoint;
			_bonus = vBonus;
			pace = vPace;
			health = vHealth;
			
			setSize(Grid.sizeTail, Grid.sizeTail, Grid.sizeTail);
			
			addEventListener(Event.ADDED_TO_STAGE, creepAddToStage);
		}

		private function creepAddToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, creepAddToStage);
			addEventListener(Event.ENTER_FRAME, onRender);
				
			var pt:Cell = _creepPoint.path[0];	
			moveTo(pt.row* Grid.sizeTail, pt.col * Grid.sizeTail, 0);
		}
	
		/**
		 * Определение направления по вектору
		 * @param	value - вектор направления (-1..1,-1..1)
		 * @return  ключ-вектор для словаря MovieClip-ов направлений
		 */
		private function selectDirection(value:Point):Point {
			var selectCourse:Point;
			
			if (value.equals(Assets.COURSE_TOP)) { selectCourse = Assets.COURSE_TOP; }
			else if (value.equals(Assets.COURSE_TOP_RIGHT)) { selectCourse = Assets.COURSE_TOP_RIGHT; }
			else if (value.equals(Assets.COURSE_RIGHT)) { selectCourse = Assets.COURSE_RIGHT; }
			else if (value.equals(Assets.COURSE_DOWN_RIGHT)) { selectCourse = Assets.COURSE_DOWN_RIGHT; }
			else if (value.equals(Assets.COURSE_DOWN)) { selectCourse = Assets.COURSE_DOWN; }
			else if (value.equals(Assets.COURSE_DOWN_LEFT)) { selectCourse = Assets.COURSE_DOWN_LEFT; }
			else if (value.equals(Assets.COURSE_LEFT)) { selectCourse = Assets.COURSE_LEFT; }
			else if (value.equals(Assets.COURSE_TOP_LEFT)) { selectCourse = Assets.COURSE_TOP_LEFT; }
			
			return selectCourse;
			
		}
	
		private function onRender(e:Event):void 
		{
			moving();
		}
		
		
		public function moving():void {
			
			var path:Vector.<Cell> = _creepPoint.path;
		
			var nextPos:uint = indPos + 1;
			if (nextPos < path.length) {
				
				// определяем направляющие движения
				var vx:int = path[nextPos].row - path[indPos].row;
				var vy:int = path[nextPos].col - path[indPos].col;
				
				// определяем точку, к которую нужно переместиться относительно текущей
				var pt:Point = new Point (vx*Grid.sizeTail, vy*Grid.sizeTail);
				// нормализуем в соответствии со скоростью - количество пикселей в кадр
				pt.normalize(speed);
				
				// задаем направление 
				course = new Point(vx, vy);
				moveBy(pt.x , pt.y , 0);
					
				// каждую секунду выбираем следующую точку для перемещения
				
				if (numFrame % cntFrameOnTail == 0) {
					// выравниваем позицию в изометрической сетке
					moveTo(path[nextPos].row * Grid.sizeTail, path[nextPos].col * Grid.sizeTail, 0);	
					_indPos++;
					numFrame = 0;
				}
				numFrame++;
				
			} else {
				removeEventListener(Event.ENTER_FRAME, onRender);
				dispatchEvent(new Event(Assets.EVENT_CREEP_FINISH, true));
			}

		}
			
		//////////////////////////////// GETTERs && SETTERs /////////////////////////////////////////////////
		
		/**
		 * направление в виде нормализованного вектора (-1..1,-1..1)
		 */
		public function get course():Point 
		{
			return _course;
		}
		
		public function set course(value:Point):void 
		{
			_course = selectDirection(value);
			var mc:Sprite = movieClips[_course];
			// смена movieClip в соответствии с направлением
			
			sprites = [mc, txtHealth];
			
			setSize(Grid.sizeTail, Grid.sizeTail, Grid.sizeTail*2);
		}
		
		public function set creepPoint(value:CreepPoint):void 
		{
			_creepPoint = value;
		}

		public function get cntFrameOnTail():uint 
		{
			return Math.ceil(Assets.FRAME_RATE/pace);
		}
		
		public function get speed():Number 
		{
			return (Grid.sizeTail*pace)/Assets.FRAME_RATE;
		}
		
		public function get indPos():uint 
		{
			return _indPos;
		}
		
		public function get health():int 
		{
			return _health;
		}
		
		public function set health(value:int):void 
		{
			_health = (value > 0?value:0);
			txtHealth.text = "h:" + _health.toString();
			txtHealth.setTextFormat(txtFormat);
			if (_health == 0) {
				this.dispatchEvent(new Event(Assets.EVENT_CREEP_DIE, true));
				_creepPoint.delCreep(this);
			}
		}
		
		public function get pace():Number 
		{
			return _pace;
		}
		
		public function set pace(value:Number):void 
		{
			_pace = (value > 0?value:0);
			txtHealth.text = "p:" + _pace.toString();
			txtHealth.setTextFormat(txtFormat);
		}
		
		public function get havingEffect():String 
		{
			return _havingEffect;
		}
		
		public function set havingEffect(value:String):void 
		{
			_havingEffect = value;
		}
		
		public function get bonus():uint 
		{
			return _bonus;
		}
		
	}

}