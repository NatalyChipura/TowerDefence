package chipura.tower 
{
	import chipura.assets.Assets;
	import movieClip.Tower2;
	/**
	 * ...
	 * @author 
	 */
	public class TowerShooterAll extends Tower 
	{
					
		public function TowerShooterAll() 
		{
			super(Assets.TOWER_ATTACK_ALL, 2, 2.5, 1.5);
			
			sprites = [new Tower2()];
		}
		
	}

}