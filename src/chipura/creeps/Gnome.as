package chipura.creeps 
{
	
	import chipura.map.Grid;
	import chipura.assets.Assets;
	
	/**
	 * Класс гномов
	 * @author 
	 */
	public class Gnome extends Creep 
	{
		
		public function Gnome(ePoint:CreepPoint, vHealth:uint, vPace:uint, vBonus:uint) 
		{
			super(ePoint, vHealth, vPace, vBonus);
			
			setSize(Grid.sizeTail, Grid.sizeTail, Grid.sizeTail);
			
			movieClips = Assets.gnomeMC();
			
		}
		
	}

}