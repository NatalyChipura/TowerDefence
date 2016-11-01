package chipura 
{
	/**
	 * Класс загрузки уровня
	 * @author Nataly Chipura
	 */
	
	import as3isolib.geom.Pt;
	import chipura.map.Cell;
	import chipura.creeps.CreepPoint;
	import chipura.map.Grid;
	import chipura.map.MapManager;
	import chipura.tower.Tower;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import chipura.assets.Assets;
	 
	public class Game extends Sprite
	{
		private var _road:Vector.<Cell>;				// координаты ячеек для дороги
		private  static var _camp:Cell;							// координаты охраняемого лагеря
		private var _creepPoints:Vector.<CreepPoint>;	// точки появления врагов (генераторы врагов)
		private var _towers:Vector.<Tower>;				// башни, размещенные на карте
		
		private var _grid:Grid;							// Изометрическая сетка
		
		private var _map:MapManager;					// карта игры
		
		private var waves:XML;							// волны
		private var cntActiveRoad:uint;				
		private var _numWave:uint = 0;
		private var idWave:uint;
		
		public function Game() 
		{
			loadLevel();
			loadWaves();
		}
				
		/**
		 * Загрузка данных уровня, координат объектов на карте
		 */
		private function loadLevel():void 
		{
			var urlLoader:URLLoader = new URLLoader();
			 
			urlLoader.addEventListener(Event.COMPLETE, loaderLevelComplete);
			urlLoader.load(new URLRequest(Assets.PATH_XML_LEVEL));

		}
		
		private function loaderLevelComplete(e:Event):void 
		{
			initLevel(new XML(e.target.data));
			dispatchEvent(new Event(Assets.EVENT_LEVEL_LOAD, true));
		}
				
		/**
		 * Загрузка данных волн для уровня
		 */
		private function loadWaves():void 
		{
			var urlLoader:URLLoader = new URLLoader();
			 
			urlLoader.addEventListener(Event.COMPLETE, loaderWaveComplete);
			urlLoader.load(new URLRequest(Assets.PATH_XML_WAVE));
		}
		
		private function loaderWaveComplete(e:Event):void 
		{
			waves = new XML(e.target.data);
			initWave();
			dispatchEvent(new Event(Assets.EVENT_WAVE_LOAD, true));
		}
		
		/**
		 * Преобразовывает данные из xml в массив координат
		 * @param	data - данные XMLList
		 * @return  массив c ячееками координат (row,col)
		 */
		private function xmlDataToArrayCell(data:XMLList):Vector.<Cell> {
			var mass:Vector.<Cell> = new Vector.<Cell>();
			
			var mapRow:Array = new Array();
			var mapCol:Array = new Array();
	
			mapRow = String(data.mapRow).split(",");
			mapCol = String(data.mapCol).split(",");
			
			for (var i:uint = 0; i < mapRow.length;i++ ) {
				mass.push(new Cell(mapRow[i],mapCol[i]));
			}
				
			return mass;
		}
		
		
		/**
		 * Инициализация игровых елементов
		 * @param	data - данные загруженного уровня
		 */
		private function initLevel(data:XML):void 
		{
			_grid = new Grid(new Pt(data.Grid.pos.@x, data.Grid.pos.@y), new Cell(data.Grid.@width, data.Grid.@length), data.Grid.@size);
			
			// инициализируем массив дороги данными из XML
			_road = new Vector.<Cell>();
			_road = xmlDataToArrayCell(data.Road);	
			
			// инициализируем массив точек выхода врагов данными из XML
			var creepEnters:Vector.<Cell> = new Vector.<Cell>();
			creepEnters = xmlDataToArrayCell(data.Enemy);	
			
			// позиция охраняемого лагеря
			_camp = new Cell(data.Camp.@row, data.Camp.@col);
			
			// создаем и инициализируем карту для поиска пути
			_map =  new MapManager(grid.cntRow, grid.cntCol);
			_map.setMaze(road);
			
			
			_creepPoints = new Vector.<CreepPoint>();
			// производим поиск путей для всех дорожек
			for (var i:uint = 0; i < creepEnters.length; i++) {
				var path:Vector.<Cell> = _map.findPath(creepEnters[i], _camp);
				
				if (_map.flFindSuccess) {
					// если путь успешно найден, создаем генераторы врагов и сохраняем найденные пути
					var cp:CreepPoint = new CreepPoint(path);
					cp.addEventListener(Assets.EVENT_WAVE_COMPLETE, onWaveComplete);
					_creepPoints.push(cp);
				}		
			}
			
			_towers = new Vector.<Tower>();
			
		}
		
		private function onWaveComplete(e:Event):void 
		{
			cntActiveRoad--;
			
			if (cntActiveRoad == 0) {
				idWave = setTimeout(initWave, 10 * 1000);	
			}
		}
		
		/**
		 * Инициализация данных волн для уровня
		 * @param	data - данные волн из XML
		 */
		private function initWave():void 
		{
			var wave:XML = waves.Wave[numWave];
			if(wave!=null){
				var cp:CreepPoint; 
				
				// выбор дороги случайным образом
				var numRoad:uint = selectRoad();
				// выбор вида врага случайным образом
				var typeCreep:String = selectTypeCreep();
				
				if (numRoad > creepPoints.length) {
					// Если выбраны несколько дорог
					cntActiveRoad = numRoad-1;
					
					// число врагов на дороге
					var cntCreepRoad:uint = Math.ceil(wave.cntCreep / creepPoints.length);
					
					// число врагов оставшихся в волне для распределения
					var cntCreepRest:uint = wave.cntCreep;
					
					for (var i:uint in creepPoints) {
						cp = creepPoints[i];
						cntCreepRoad = (cntCreepRest > cntCreepRoad)?cntCreepRoad:cntCreepRest;
						cntCreepRest -= cntCreepRoad;
					
						if (cntCreepRoad > 0) {
							setTimeout(cp.start, i * 6000, typeCreep, cntCreepRoad, wave.distance, wave.Creep.health, wave.Creep.pace, wave.prise);
							typeCreep = selectTypeCreep();
						}
					}
					
				} else {
					// если выбранна конкретная дорога
					cntActiveRoad = 1;
					cp = creepPoints[numRoad-1];
					cp.start(typeCreep,wave.cntCreep,wave.distance,wave.Creep.health,wave.Creep.pace, wave.prise);
				}
				
				_numWave++;
				
				dispatchEvent(new Event(Assets.EVENT_WAVE_NEW));
			}
		}
				
		/**
		 * выбор дороги случайным образом
		 * 1 - первая дорога
		 * 2 - вторая дорога
		 * ....
		 * N - обе дороги
		 */
		private function selectRoad():uint
		{
			return Math.ceil(Math.random() * (creepPoints.length+1));
		}
		
		/**
		 * выбор типа врага случайным образом (Орк, Гном, ....)
		 */	
		private function selectTypeCreep():String 
		{
			var str:String;
			switch(Math.ceil(Math.random() * 2)) {
				case 1: str = Assets.CREEP_TYPE_ORK; break;
				case 2: str = Assets.CREEP_TYPE_GNOME; break;
			}
			
			return str;
		}
		
		public function addTower(tower:Tower):void {
			_towers.push(tower);
		}
		
		public function gameOver():void 
		{
			trace("GAME OVER");
			clearTimeout(idWave);
			
			for each (var cp:CreepPoint in creepPoints) {
				cp.removeEventListener(Assets.EVENT_WAVE_COMPLETE, onWaveComplete);
			}
		}
		
		////////////////////////// GETTERs && SETTERs  //////////////////////////////////////
		
		public function get road():Vector.<Cell> 
		{
			return _road;
		}
		
		public function get creepPoints():Vector.<CreepPoint> 
		{
			return _creepPoints;
		}
		
		public static function get camp():Cell 
		{
			return _camp;
		}
		
		public function get grid():Grid 
		{
			return _grid;
		}
		
		public function get map():MapManager 
		{
			return _map;
		}
		
		public function get numWave():uint 
		{
			return _numWave;
		}
		
		public function get towers():Vector.<Tower> 
		{
			return _towers;
		}
	
	}

}