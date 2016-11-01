package chipura
{
	
	import as3isolib.core.IsoContainer;
	import as3isolib.data.INode;
	import as3isolib.display.primitive.IsoRectangle;
	import as3isolib.graphics.SolidColorFill;
	import chipura.assets.Assets;
	import chipura.map.Cell;
	import chipura.map.Grid;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import as3isolib.display.IsoView;
	import as3isolib.display.scene.IsoScene;
	import as3isolib.display.IsoSprite;
	import as3isolib.geom.Pt;
	import as3isolib.core.IsoDisplayObject;
	import eDpLib.events.ProxyEvent;
	
	import movieClip.Tower1;
	import movieClip.Tower2;
	import movieClip.Tower3;
	
	/**
	 * ...
	 * @author
	 */
	public class InterfaceManager extends Sprite
	{
		private var towerView:IsoView;
		
		private var towerMC:Array = [Assets.TOWER_SPRITE_SHOOTER,  Assets.TOWER_SPRITE_SHOOTERALL, Assets.TOWER_SPRITE_FREEZER];
		private var towerIcon:Dictionary = new Dictionary();
		private var towerPrice:Dictionary = new Dictionary();
		
		private var _selectTower:IsoDisplayObject;
		
		private var _scene:IsoScene = new IsoScene();
		private var _stage:Sprite;
		
		private var rectTower:IsoRectangle;
		private var rectDistance:IsoRectangle;
		
		private var curPos:Cell;
		
		private var _coins:uint = Assets.COINS_DEFAULT_CNT;
		
		private var infoTxt:TextField = new TextField();
		private var txtFormat:TextFormat;
		private var info:Dictionary = new Dictionary;
		
		
		/**
		 * флаг определяет можно ли поместить башню в данном месте карты
		 */ 
		public var flTowerCanPut:Boolean = false;
		
		public function InterfaceManager()
		{
			towerIcon[Assets.TOWER_TYPE_SHOOTER] = Assets.TOWER_SPRITE_SHOOTER;
			towerIcon[Assets.TOWER_TYPE_SHOOTERALL] = Assets.TOWER_SPRITE_SHOOTERALL;
			towerIcon[Assets.TOWER_TYPE_FREEZER] = Assets.TOWER_SPRITE_FREEZER;
			
			towerPrice[Assets.TOWER_TYPE_SHOOTER] = Assets.TOWER_PRICE_SHOOTER;
			towerPrice[Assets.TOWER_TYPE_SHOOTERALL] = Assets.TOWER_PRICE_SHOOTERALL;
			towerPrice[Assets.TOWER_TYPE_FREEZER] = Assets.TOWER_PRICE_FREEZER;
		}
	
		public function addPanelTower(stage:Sprite):void
		{
			createPanelTower();
			
			_stage = stage;
			_stage.addChild(towerView);
			towerView.x = _stage.width / 2 - towerView.width / 2;
			
			txtFormat = new TextFormat(); 
			txtFormat.color = 0xFFFFFF; 
			txtFormat.size = 16;
			infoTxt.width = 200;
			
			addChild(infoTxt);
			
		}
		
		// создаем панель с иконками башен
		private function createPanelTower():void
		{
			//сцена для блоков
			var towerScene:IsoScene = new IsoScene();
			towerScene.removeAllChildren();
			
			towerView = new IsoView();
			towerView.setSize(250, 90);
			towerView.centerOnPt(new Pt(0, 0, 0), false);
			towerView.addScene(towerScene);
			
			var p:Point = new Point(50, 70);
			
			for (var name:String in towerIcon) {
				
				var tower:IsoSprite = new IsoSprite();
				tower.name = name;
				
				tower.sprites = [scaleSprite(towerIcon[name],0.45)];
				
				var isoP:Pt = towerView.localToIso(p);
				tower.moveTo(isoP.x + tower.width, isoP.y+tower.length/2, 0);
				p = towerView.isoToLocal(isoP);
				p.x += 70;
				
				tower.addEventListener(MouseEvent.ROLL_OVER, onRollOverHandler);
				tower.addEventListener(MouseEvent.ROLL_OUT, onRollOutHandler);
				
				towerScene.addChild(tower);
				towerScene.render();
			}
			
			addEventListener(Event.ENTER_FRAME, onRender);
		}
		
		public function delPanelTower():void
		{
			towerView.removeAllScenes();
			towerView.setSize(0, 0);
			towerView = null;
		}
		
		private function scaleSprite(mc:Sprite, scaleValue:Number):Sprite
		{
			var className:String = getQualifiedClassName(mc).split('::').join('.');;
			var NewSprite:Class = getDefinitionByName(className) as Class;
			var newMc:* = new NewSprite();
			newMc.scaleX = newMc.scaleY = scaleValue;
			return newMc;
		}
		
		protected function onIconClick(e:ProxyEvent):void
		{
			// инициализируем выбранную башню
			var target:IsoDisplayObject = e.target as IsoDisplayObject;
			
			_selectTower = target.clone();
			_selectTower.name = target.name;

			rectTower = new IsoRectangle();
			rectTower.setSize(Assets.TOWER_SIZE*Grid.sizeTail, Assets.TOWER_SIZE*Grid.sizeTail, 0);
			rectTower.moveTo(_selectTower.x-rectTower.width/2, _selectTower.y-rectTower.length/2, _selectTower.z);
			rectTower.fill = new SolidColorFill(0x00FF00, 0.3);
			
			rectDistance = new IsoRectangle();
			rectDistance.setSize((Assets.TOWER_SIZE+2*Assets.TOWER_DISTANCE)*Grid.sizeTail, (Assets.TOWER_SIZE+2)*Grid.sizeTail, 0);
			rectDistance.moveTo(_selectTower.x-rectTower.width/2, _selectTower.y-rectTower.length/2, _selectTower.z);
			rectDistance.fill = new SolidColorFill(0xFFFFFF, 0.3);
		//	_selectTower.addChild(rect as INode);
			
	
			if (_selectTower is IsoSprite) {
				(_selectTower as IsoSprite).sprites = [scaleSprite(towerIcon[_selectTower.name],1)];
				((_selectTower as IsoSprite).sprites[0] as Sprite).alpha = 0.7;
			}
			
			scene.removeAllChildren();
			scene.addChild(rectDistance);
			scene.addChild(rectTower);
			scene.addChild(_selectTower);
			scene.render();
			
			_selectTower.addEventListener(MouseEvent.MOUSE_UP, onTowerDrop, false, 0, true);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMoveTower, false, 0, true);
			
			curPos = new Cell(Math.ceil(_selectTower.x / Grid.sizeTail), Math.ceil(_selectTower.y / Grid.sizeTail));
		
		
			   //  _selectTower.addEventListener(MouseEvent.MOUSE_DOWN, onPickup, false, 0, true);
			
			dispatchEvent(new Event(Assets.EVENT_PANEL_TOWER_SELECT,true));
		}
		
		private function onMoveTower(e:MouseEvent):void
		{
			var newPos:Cell = new Cell(Math.ceil(_selectTower.x / Grid.sizeTail), Math.ceil(_selectTower.y / Grid.sizeTail));
			
			if (!newPos.equals(curPos)) {
			
				curPos = new Cell(newPos.row, newPos.col);
			
				rectTower.moveTo(_selectTower.x - rectTower.width / 2, _selectTower.y - rectTower.length / 2, _selectTower.z);
				rectDistance.moveTo(_selectTower.x - rectDistance.width / 2, _selectTower.y - rectDistance.length / 2, _selectTower.z);
				
				dispatchEvent(new Event(Assets.EVENT_PANEL_TOWER_MOVE, true));
			}

			scene.render();
			
		}
		
		private function onTowerDrop(e:ProxyEvent):void 
		{
			if(flTowerCanPut){
				_selectTower.removeEventListener(MouseEvent.MOUSE_UP, onTowerDrop);
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMoveTower);
				
				_coins -= towerPrice[_selectTower.name];
								
				dispatchEvent(new Event(Assets.EVENT_PANEL_TOWER_DROP, true));
			}
		}
		
		private function onRollOverHandler(e:ProxyEvent):void
		{
			var icon:IsoDisplayObject = (e.target as IsoDisplayObject);
			var flAvailableTower:Boolean = towerPrice[icon.name] <= coins;
			
			if (flAvailableTower) {				
				icon.addEventListener(MouseEvent.MOUSE_DOWN, onIconClick);
			} else {				
				icon.removeEventListener(MouseEvent.MOUSE_DOWN, onIconClick);
			}
			
			var glow:GlowFilter = new GlowFilter(flAvailableTower?0x00FF00:0xFF0000, 1, 10, 10, 1);
			icon.container.filters = [glow];
			
			addInfo("cost of tower",towerPrice[icon.name])
		}
		
		private function onRollOutHandler(e:ProxyEvent):void
		{
			(e.target as IsoDisplayObject).container.filters = [];
			delInfo("Cost of Tower")
		}
		
		public function addInfo(description:String,value:String = ""):void {
			var desc:String = description.substr(0,1).toUpperCase()+description.substr(1,description.length).toLowerCase();
			info[desc] = value;
		}
		
		private function delInfo(description:String):void 
		{
			var desc:String = description.substr(0,1).toUpperCase()+description.substr(1,description.length).toLowerCase();
			delete info[desc];
		}
				
		private function onRender(e:Event):void 
		{
			infoTxt.text = "";
			
			addInfo("Coins",coins.toString());
			
			for (var desc:String in info) {
				infoTxt.text = infoTxt.text + desc + (info[desc]!=""?": " + info[desc] + "\n":"\n");
			}
			infoTxt.setTextFormat(txtFormat);
		}
		
		
		/////////////////////////////  GETTERs && SETTERs ///////////////////////////////////////////
		
		public function get selectTower():IsoDisplayObject
		{
			return _selectTower;
		}
		
		public function get scene():IsoScene 
		{
			return _scene;
		}
		
		public function get coins():uint 
		{
			return _coins;
		}
		
		public function set coins(value:uint):void 
		{
			_coins = (value<0?0:value);
		}
	
	}

}