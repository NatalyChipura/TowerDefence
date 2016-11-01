package chipura
{
	import as3isolib.display.primitive.IsoHexBox;
	import as3isolib.display.primitive.IsoRectangle;
	import as3isolib.events.IsoEvent;
	import as3isolib.geom.Pt;
	import as3isolib.graphics.SolidColorFill;
	import chipura.creeps.Creep;
	import chipura.creeps.CreepPoint;
	import chipura.map.Cell;
	import chipura.map.Grid;
	import chipura.tower.Tower;
	import chipura.tower.TowerFreezer;
	import chipura.tower.TowerShooter;
	import chipura.tower.TowerShooterAll;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import as3isolib.display.IsoSprite;
	import as3isolib.display.IsoView;
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.scene.IsoScene;
	
	import chipura.assets.Assets;
	import chipura.creeps.Gnome;
	import chipura.Game;
	
	/**
	 * Главный класс прототипа игры TowerDefence
	 * @author Nataly Chipura
	 */
	public class Main extends Sprite
	{
		// данные уровня
		private var game:Game;
		
		// изометрический вывод
		public var viewPort:IsoView;
		// изометрическая сцена
		private var scene:IsoScene;
		private var sceneGrid:IsoScene;
		
		// панель интерфейса
		private var panel:InterfaceManager;
		
		private var cntFinish:uint = 0;

		
		public function Main()
		{
			if (stage){
				init();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
			
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.frameRate = Assets.FRAME_RATE;
			
			// создаем изометрический вьюпорт для вывода изометрии
			viewPort = new IsoView();
			viewPort.setSize(stage.stageWidth, stage.stageHeight);
			addChildAt(viewPort, 0);
			
			// добавляем фон карты
			Assets.mapBitmap.width = stage.stageWidth;
			Assets.mapBitmap.height = stage.stageHeight;
			addChildAt(Assets.mapBitmap, 0);
			
			// инициализируем игровой мир
			game = new Game();
			game.addEventListener(Assets.EVENT_LEVEL_LOAD, onLoadLevel);
		
		}
		
		// уровень загружен
		private function onLoadLevel(e:Event):void
		{
			game.removeEventListener(Assets.EVENT_LEVEL_LOAD, onLoadLevel);
			
			
			//задаем позицию изометрического вьюпорта
			viewPort.centerOnPt(game.grid.pos, false);
			
			// создаем сцену вывода объектов в изометрии
			scene = new IsoScene();
			viewPort.addScene(scene);
			
			sceneGrid = new IsoScene();
			sceneGrid.addChild(game.grid);
						
			panel = new InterfaceManager();
			panel.addPanelTower(this);
			viewPort.addScene(panel.scene);
			addChild(panel);
			panel.addEventListener(Assets.EVENT_PANEL_TOWER_SELECT, onSelectTower);
			
			for each(var creepPoint:CreepPoint in game.creepPoints) {
				creepPoint.addEventListener(Assets.EVENT_CREEP_ADD, onAddCreep);
			}
			
			addEventListener(Event.ENTER_FRAME, onRender);
			game.addEventListener(Assets.EVENT_WAVE_NEW, onNewWave);
		}
		
		private function onAddCreep(e:Event):void 
		{
			var creepPoint:CreepPoint = (e.target as CreepPoint);
			var creep:Creep = creepPoint.creeps[creepPoint.creeps.length - 1];
			scene.addChild(creep);
			
			stage.addEventListener(Assets.EVENT_CREEP_DIE, onRemoveCreep);
			stage.addEventListener(Assets.EVENT_CREEP_FINISH, onFinish);
		}
		
		
		/**
		 * Событие выбора башни из панели интерфейса
		 * @param	e
		 */		
		private function onSelectTower(e:Event):void
		{
			var pt:Pt = viewPort.localToIso(new Pt(stage.mouseX, stage.mouseY));
		//	curPos = new Cell(Math.ceil(pt.x / Grid.sizeTail), Math.ceil(pt.y / Grid.sizeTail));
		
			showGrid();
		
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMoveTower, false, 0, true);
			panel.addEventListener(Assets.EVENT_PANEL_TOWER_MOVE, onCheckPut);
			panel.addEventListener(Assets.EVENT_PANEL_TOWER_DROP, onTowerDrop);
			viewPort.addEventListener(MouseEvent.MOUSE_UP, onTowerDrop);
		}
		
		/**
		 * Событие перемещения башни за мышкой
		 * @param	e
		 */
		private function onMoveTower(e:MouseEvent):void
		{
			var pt:Pt = viewPort.localToIso(new Pt(stage.mouseX, stage.mouseY));
			pt.setTo(Math.ceil(pt.x / Grid.sizeTail) * Grid.sizeTail, Math.ceil(pt.y / Grid.sizeTail) * Grid.sizeTail);
			
			if (Assets.TOWER_SIZE & 1) {
				pt.offset(-Grid.sizeTail / 2,-Grid.sizeTail / 2)
			}
			
			panel.selectTower.moveTo(pt.x, pt.y, panel.selectTower.z);
		}
		
		/**
		 * Проверка возможности поместить башню на карту при смене ячейки
		 * @param	e
		 */
		private function onCheckPut(e:Event):void 
		{
			// проверяем находится ли башня в допустимых областях (на удаленном расстоянии от дороги и других башен)
		
			// текущая позиция башни - индексы ячейки
			var posTower:Cell = new Cell(Math.ceil(panel.selectTower.x/Grid.sizeTail),Math.ceil(panel.selectTower.y/Grid.sizeTail))
				
			var sizeTowerZone:uint = Assets.TOWER_SIZE+ 2*Assets.TOWER_DISTANCE;
			var n:Number = sizeTowerZone / 2;

			// инициализация ячейки, которую будем проверять, начальными значениями
			var checkCell:Cell = new Cell(posTower.row - n, posTower.col - n);
			
			// проверяем все ячейки зоны башни до первого пересечения
			var i:int = 0;
			var j:int;
			var flCheck:Boolean = true;
			while (i < sizeTowerZone && flCheck) {
				j = 0;
				while (j < sizeTowerZone && flCheck) {
					flCheck = !game.map.isMapCellBusy(new Cell(checkCell.row + i, checkCell.col + j));
					j++;
				}
				i++;
			}
			
			panel.flTowerCanPut = flCheck;
		}
		
		/**
		 * Событие отпускания башни - попытка поместить башню на игровое поле
		 * @param	e
		 */
		private function onTowerDrop(e:Event):void 
		{
			
			if (panel.flTowerCanPut) {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMoveTower);
				panel.removeEventListener(Assets.EVENT_PANEL_TOWER_MOVE, onCheckPut);
				panel.removeEventListener(Assets.EVENT_PANEL_TOWER_DROP, onTowerDrop);
				viewPort.removeEventListener(MouseEvent.MOUSE_UP, onTowerDrop);
				
				
				// Создаем объект башни в игре
				var tower:Tower;
				switch(panel.selectTower.name) {
					case Assets.TOWER_TYPE_SHOOTER: tower = new TowerShooter(); break;
					case Assets.TOWER_TYPE_SHOOTERALL: tower = new TowerShooterAll(); break;
					case Assets.TOWER_TYPE_FREEZER: tower = new TowerFreezer(); break;
				}
			
				tower.moveTo(panel.selectTower.x, panel.selectTower.y, 0);
				scene.addChild(tower);
				
				// Отмечаем башню на карте
				game.map.setTower(new Cell(Math.ceil(panel.selectTower.x / Grid.sizeTail), Math.ceil(panel.selectTower.y / Grid.sizeTail)));
			
			
				hideGrid();
				panel.scene.removeAllChildren();
				
				game.addTower(tower);
				
			}
		}
		   	
		private function showGrid():void {
			viewPort.removeAllScenes();

			viewPort.addScene(sceneGrid);
			
			game.map.initScene();
			viewPort.addScene(game.map.scene);
						
			viewPort.addScene(scene);
			
			viewPort.addScene(panel.scene);
			
			sceneGrid.render();
			
		}
		
			
		private function hideGrid():void 
		{
			viewPort.removeAllScenes();
			
			viewPort.addScene(scene);
			viewPort.addScene(panel.scene);
			scene.render();
		}
		
		
		private function onFinish(e:Event):void 
		{
			
			removeCreep(e.target as Creep);
			cntFinish++;
			
			// игра окончена
			if (cntFinish >= 5) {
				panel.addInfo("GAME OVER !!!");
				game.gameOver();
				// Уничтожить объекты
				scene.removeAllChildren();
				viewPort.removeAllScenes();
				
				panel.delPanelTower();
				
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMoveTower);
				viewPort.removeEventListener(MouseEvent.MOUSE_UP, onTowerDrop);
				panel.removeEventListener(Assets.EVENT_PANEL_TOWER_MOVE, onCheckPut);
				panel.removeEventListener(Assets.EVENT_PANEL_TOWER_DROP, onTowerDrop);
				game.removeEventListener(Assets.EVENT_WAVE_NEW, onNewWave);
				removeEventListener(Event.ENTER_FRAME, onRender);
			
			}
		}
		
		private function onNewWave(e:Event):void 
		{
			panel.addInfo("Wave", game.numWave.toString());
			
		}
		
		private function onRemoveCreep(e:Event):void 
		{
			var creep:Creep = e.target as Creep;
			removeCreep(creep);
			panel.coins += creep.bonus;
		}
		
		private function removeCreep(creep:Creep):void {
			scene.removeChild(creep);	
		}		
		
		private function onRender(e:Event):void
		{
			for each (var tower:Tower in game.towers) {
				for each (var creepPoint:CreepPoint in game.creepPoints) {
					
					if (creepPoint.creeps.length > 0) {
						tower.checkCreepInArea(creepPoint.creeps);
					}
				}
			}
	
			scene.render();
		}
		
		
		
		
	}
	
	

}