package chipura.tower 
{
	import as3isolib.core.IsoDisplayObject;
	import as3isolib.display.IsoSprite;
	import as3isolib.geom.Pt;
	import chipura.assets.Assets;
	import chipura.creeps.Creep;
	import chipura.Game;
	import chipura.map.Grid;
	import eDpLib.events.ProxyEvent;
	import flash.events.Event;
	import flash.utils.setTimeout;
	/**
	 * Класс управления Башнями (Tower)
	 * @author Nataly Chipura
	 */
	public class Tower extends IsoSprite
	{		
		
		protected var _damage:uint;
		protected var _attackRadius:Number;
		protected var _speedShot:Number;
		protected var _damageEffect:Number = 0;
		protected var _timeEffect:uint;
		
		protected var cost:uint;
		
		/**
		 * Тип наносимого урона - Поражение одного, урон всем
		 */
		protected var _damageType:String;
		
		/**
		 * Тип наносимого эффекта - замедление,.....
		 */
		protected var _effectType:String = Assets.EFFECT_TYPE_NONE;
		
	
		private var cntFrameForShot:uint;
		private var numFrame:uint = 0;
		private var attackedCreeps:Vector.<Creep> = new Vector.<Creep>();
		
	//	protected var _sprite:
		
		public function Tower(vTypeDamage:String, vDamage:uint,vRadius:Number,vSpeedShot:Number,vEffect:String = Assets.EFFECT_TYPE_NONE,vDamageEffect:Number = 0, vTimeEffect:Number = 0) 
		{
			_damageType = vTypeDamage;
			_damage = vDamage;
			_attackRadius = vRadius;
			_speedShot = vSpeedShot;
			_effectType = vEffect;
			_damageEffect = vDamageEffect;
			_timeEffect = vTimeEffect;
			
			setSize(Grid.sizeTail, Grid.sizeTail, Assets.TOWER_SIZE*Grid.sizeTail);
				
			cntFrameForShot = uint(Assets.FRAME_RATE / _speedShot);
			
			addEventListener(Event.ADDED_TO_STAGE, towerAddToStage);
		}
		
		private function towerAddToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, towerAddToStage);
			addEventListener(Event.ENTER_FRAME, onRender);
		}
		
		/**
		 * Проверяем врагов на вхождение в область действия башни
		 * @param	creep - проверяемый враг
		 */
		public function checkCreepInArea(creeps:Vector.<Creep>):void 
		{
			var ptCreep:Pt;
			var ptTower:Pt = new Pt(this.x, this.y, this.z);
			var da:Number = (Assets.TOWER_SIZE & 1?Grid.sizeTail/2:Grid.sizeTail)
		//	ptTower.offset(da, da);
			var distance:Number; 
			var i:uint;
			
			var radius:Number = ((Assets.TOWER_SIZE / 2) + attackRadius);
			
			for each (var creep:Creep in creeps) {
				ptCreep = new Pt(creep.x, creep.y, creep.z);
				da = Grid.sizeTail / 2;
				ptCreep.offset(da, da);
				distance = Pt.distance(ptTower, ptCreep) / Grid.sizeTail;

				if ( distance <= radius) {
					// формируем массив врагов, которые попадают под атаку
					if (attackedCreeps.indexOf(creep)==-1) {
						attackedCreeps.push(creep);
					}
				} else {
					// убираем тех врагов, которые уже вышли из поля башни
					i = attackedCreeps.indexOf(creep);
					if (i!=-1) {
						attackedCreeps.splice(i,1);
					}
				}
			}
		
			if (attackedCreeps.length > 0 && damageType == Assets.TOWER_ATTACK_ONE) {
				selectLeaderCreep();
			}
		
		}
		
		/**
		 * Находим ближайшего к выходу врага - лидера
		 */
		private function selectLeaderCreep():void {
			
			var leader:Creep = attackedCreeps.shift();
			var ptCreep:Pt = new Pt(leader.x, leader.y, leader.z);;
			var ptCamp:Pt = new Pt(Game.camp.x * Grid.sizeTail, Game.camp.y * Grid.sizeTail, 0);
			var minDistance:Number = Pt.distance(ptCamp, ptCreep) / Grid.sizeTail;
			
			var distance:Number;
			
			for each (var creep:Creep in attackedCreeps) {
				ptCreep = new Pt(creep.x, creep.y, creep.z);
				distance = Pt.distance(ptCamp, ptCreep) / Grid.sizeTail;
				if (distance < minDistance) {
					minDistance = distance;
					leader = creep;
				}
			}
			
			attackedCreeps.length = 0;
			attackedCreeps.push(leader);
		}
		
		private function onRender(e:Event):void 
		{
			var flCanShot:Boolean = (numFrame % cntFrameForShot == 0);	
			
			if (attackedCreeps.length > 0 && flCanShot) {
				shot();
				if(effectType!=Assets.EFFECT_TYPE_NONE) applyEffect();		
				flCanShot = false;
				numFrame = 0;
			} 
			
			if (!flCanShot) {
				numFrame++;
			} 
			
		}
		
		// накладываем эффект
		private function applyEffect():void 
		{
			for each(var creep:Creep in attackedCreeps) {
				effect(creep);
					
				creep.havingEffect = effectType;
				setTimeout(cancelEffect, timeEffect * 1000, creep);
			
			}
			
		}
		
		protected function effect(creep:Creep):void 
		{
			// действие эффекта
		}
		
		// снимаем эффект эффект
		protected function cancelEffect(creep:Creep):void 
		{
			creep.havingEffect = Assets.EFFECT_TYPE_NONE;
			attackedCreeps.splice(attackedCreeps.indexOf(creep), 1);
		}
		
		// совершаем выстрел
		private function shot():void 
		{
			// всем врагам, попадающих под атаку, наносим урон
			for (var i:uint in attackedCreeps) {
				var creep:Creep = attackedCreeps[i];
				creep.health -= damage;
				
				// если враг повержен, удаляем его
				if (creep.health == 0) {
				    attackedCreeps.splice(i, 1);
				}
			}
		}
		
		/////////////////////// GETTERs && SETTERs /////////////////////////////////////
		
		public function get damage():uint 
		{
			return _damage;
		}
		
		public function get attackRadius():Number 
		{
			return _attackRadius;
		}
		
		public function get speedShot():Number 
		{
			return _speedShot;
		}
		
		public function get damageEffect():Number 
		{
			return _damageEffect;
		}
		
		
		public function get damageType():String 
		{
			return _damageType;
		}
		
		public function get timeEffect():uint 
		{
			return _timeEffect;
		}
		
		public function get effectType():String 
		{
			return _effectType;
		}
	
	}

}