package chipura.creeps 
{
	import chipura.creeps.CreepPoint;
	import chipura.assets.Assets;
	import chipura.map.Grid;
	
	/**
	 * Класс Орка 
	 * @author NatalyChipura
	 */
	public class Ork extends Creep 
	{
		
		public function Ork(ePoint:CreepPoint, vHealth:uint, vPace:uint, vBonus:uint) 
		{
			super(ePoint, vHealth, vPace,vBonus);

			setSize(Grid.sizeTail, Grid.sizeTail, Grid.sizeTail * 2);
			
			movieClips = Assets.orkMC();
			
		}		
	}

}