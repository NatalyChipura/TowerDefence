package chipura.map 
{
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.geom.Pt;
	
	import chipura.map.Cell;
	import chipura.assets.Assets;
	
	/**
	 * ...
	 * @author 
	 */
	public class Grid extends IsoGrid
	{
		private static var _sizeTail:uint;
		private var _cntCol:uint;
		private var _cntRow:uint;
		private var _pos:Pt;
		
		
		public function Grid(pos:Pt,sizeGrid:Cell,sizeTail:uint) 
		{
			_sizeTail = cellSize = sizeTail;
			_cntCol = sizeGrid.col;
			_cntRow = sizeGrid.row;
			_pos = pos;
			
			setGridSize(_cntRow, _cntCol, 1);
		//	Assets.sizeTail = sizeTail;
		}
		
		public function get pos():Pt 
		{
			return _pos;
		}
		
		public function get cntCol():uint 
		{
			return _cntCol;
		}
		
		public function get cntRow():uint 
		{
			return _cntRow;
		}
		
		static public function get sizeTail():uint 
		{
			return _sizeTail;
		}
		
	}

}
