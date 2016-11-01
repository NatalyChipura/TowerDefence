package chipura.map 
{
	import flash.geom.Point;
	/**
	 * Класс ячейки матрицы
	 * @author NatalyChipura
	 */
	public class Cell  extends Point
	{
		// индексы ячейки - номер строки и столбца
		private var _col:int;
		private var _row:int;
		
		public function Cell(row:int=0, col:int=0) 
		{
			super(row, col);			
		}		
		
		public function get col():int 
		{
			return y;
		}
		
		public function get row():int 
		{
			return x;
		}
	}

}