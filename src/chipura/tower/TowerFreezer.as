package chipura.tower 
{
	import chipura.assets.Assets;
	import chipura.creeps.Creep;
	import movieClip.Tower3;
	/**
	 * Класс башни замедлителя
	 * @author Nataly Chipura
	 */
	public class TowerFreezer extends Tower 
	{
		private var defPace:uint;   // изначальная скорость
		
		public function TowerFreezer() 
		{
			super(Assets.TOWER_ATTACK_ONE, 0, 1.5, 0.5, Assets.EFFECT_TYPE_FREEZE, 0.25, 2);
			
			sprites = [new Tower3()];
		}
		
		// уменьшаем скорость
		override protected function effect(creep:Creep):void {
			super.effect(creep);
			
			// проверяем имеет ли враг такой эффект
			if (creep.havingEffect != effectType) {
				defPace = creep.pace;
				creep.pace -= creep.pace*damageEffect;
			}
			
		}
		
		// возвращаем прежную скорость
		override protected function cancelEffect(creep:Creep):void {
			super.cancelEffect(creep);

			creep.pace = defPace;
		}
		
		
	}

}