package chipura.tower 
{
	import chipura.assets.Assets;
	import movieClip.Tower1;
	/**
	 * ...
	 * @author 
	 */
	public class TowerShooter extends Tower 
	{
				
		public function TowerShooter() 
		{
			super(Assets.TOWER_ATTACK_ONE, 4, 4, 1.5);
			
			sprites = [new Tower1()];
		}
		
	}

}