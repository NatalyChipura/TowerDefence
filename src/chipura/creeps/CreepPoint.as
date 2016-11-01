package chipura.creeps 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import as3isolib.display.IsoSprite;
	import as3isolib.geom.Pt;
	
	import chipura.assets.Assets;
	import chipura.map.Cell;
	import chipura.creeps.Creep;
	import chipura.creeps.Gnome;
	import chipura.creeps.Ork;
	import chipura.map.Grid;
	

	/**
	 * Точка выхода врага - отвечает за генерацию врагов
	 * и содержит маршрут движения для заданной точки до финиша
	 * @author Nataly Chipura
	 */
	public class CreepPoint extends Sprite
	{
		
		private var _path:Vector.<Cell> = new Vector.<Cell>();
			
		private var indexTail:uint = 0;
		private var _newCreep:Creep;
		
		private var _typeCreep:String = Assets.CREEP_TYPE_ORK;
		
		private var healthCreep:uint;
		private var paceCreep:uint;
		private var bonusCreep:uint;
		
		private var _cntCreep:uint;
		private var numCreep:uint = 0;
		private var _distance:uint = Assets.ENEMY_DISTANCE; 	// расстояние между врагами
		
		private var _creeps:Vector.<Creep>;
		
		
		/**
		 * Конструктор генератора врагов
		 * @param	enemyPath - путь движения враго
		 */
		public function CreepPoint(enemyPath:Vector.<Cell>) 
		{
			path = enemyPath;
		
			_creeps = new Vector.<Creep>();
		}
		
		/**
		 * Запуск цепочки врагов c параметрами волны
		 * @param	vCntCreep
		 * @param	vDistance
		 * @param	vHealth
		 * @param	vPace
		 */
		 
		public function start(vTypeCreep:String = Assets.CREEP_TYPE_GNOME, vCntCreep:uint = 3, vDistance:uint = Assets.ENEMY_DISTANCE, vHealth:uint = 10, vPace:uint = 1, vBonus:uint = 1):void {
			cntCreep = vCntCreep;
			
			if (cntCreep > 0) {
				typeCreep = vTypeCreep;
				distance = vDistance;
				healthCreep = vHealth;
				paceCreep = vPace;
				bonusCreep = vBonus;
				
				numCreep = 0;
				
				addCreep();
				addEventListener(Event.ENTER_FRAME, onRender);
			}
		}
		
		/**
		 * Добавление врага
		 */
		private function addCreep():void 
		{
			var creep:Creep;
			
			switch(typeCreep) {
				case Assets.CREEP_TYPE_GNOME: creep =  new Gnome(this,healthCreep,paceCreep,bonusCreep); break;
				case Assets.CREEP_TYPE_ORK:	creep =  new Ork(this,healthCreep,paceCreep,bonusCreep); break;
			}
		
			_creeps.push(creep);
			_newCreep = creep;

			numCreep++;
			dispatchEvent(new Event(Assets.EVENT_CREEP_ADD, true));
		}
		
		public function delCreep(creep:Creep):void 
		{
			trace("del",_creeps.indexOf(creep),_creeps);
			_creeps.splice(_creeps.indexOf(creep), 1);
		}
		
		public function onRender(e:Event):void
		{
			
			// проверяем закончилась ли волна
			if(numCreep<cntCreep){
				indexTail = newCreep.indPos + 1;
				// проверяем дистанцию между врагами
				if (indexTail % (distance+2) == 0) {
					addCreep();
				} 
			} else {
				removeEventListener(Event.ENTER_FRAME, onRender);
				dispatchEvent(new Event(Assets.EVENT_WAVE_COMPLETE));
			}
			
		}
		
		//////////////////// GETTERs & SETTERs /////////////////////////////////////
		
		/**
		 * путь - массив с координатами ячеек для данной EnemyPoint
		 */
		public function get path():Vector.<Cell> 
		{
			return _path;
		}
		
		public function set path(value:Vector.<Cell>):void 
		{
			for (var i:uint = 0; i < value.length;i++){
				_path[i] = value[i];
			}
		}
		
		public function get newCreep():Creep 
		{
			return _newCreep;
		}
		
		/**
		 *  Тип врага - (Орк, Гном, ...)
		 */
		public function get typeCreep():String 
		{
			return _typeCreep;
		}
		
		/**
		 *  Тип врага - (Орк, Гном, ...)
		 */
		public function set typeCreep(value:String):void 
		{
			switch(value) {
				case Assets.CREEP_TYPE_GNOME: _typeCreep = Assets.CREEP_TYPE_GNOME; break;
				case Assets.CREEP_TYPE_ORK:   _typeCreep = Assets.CREEP_TYPE_ORK;   break;
				default: _typeCreep = Assets.CREEP_TYPE_GNOME; break;
			}
		}
		
		
		/**
		 * Количество врагов в текущую волну
		 */
		public function get cntCreep():uint 
		{
			return _cntCreep;
		}
		
		/**
		 * Количество врагов в текущую волну
		 */
		public function set cntCreep(value:uint):void 
		{
			_cntCreep = value<=0?1:value;
		}
		
		public function set distance(value:uint):void 
		{
			_distance = value<=0?Assets.ENEMY_DISTANCE:value;
		}
		
		public function get distance():uint 
		{
			return _distance;
		}
		
		public function get creeps():Vector.<Creep> 
		{
			return _creeps;
		}
		
	}

}