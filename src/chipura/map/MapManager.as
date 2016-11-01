package chipura.map 
{
	import as3isolib.display.primitive.IsoRectangle;
	import as3isolib.display.scene.IsoScene;
	import as3isolib.graphics.SolidColorFill;
	import chipura.assets.Assets;
	import flash.geom.Point;
	/**
	 * Конструктор поиска пути в лабиринте
	 * @author Nataly Chipura
	 */
	public class MapManager 
	{
		private const CELL_FINISH:uint = 0;
		private const CELL_START:uint = 253;
		private const CELL_ROAD:uint = 254;
		private const CELL_WALL:uint = 255;
		
		private const CELL_TOWER:uint = 1;
		
		// размер лабиринта (количество столбцов и строк)
		private var cntCol:uint;
		private var cntRow:uint;
		
		// текущий номер волны
		private var wi:uint = 0;
		// максимально допустимая длина волны
		private var wk:uint = 0;
		
		/**
		 * Матрица карты с установленными на ней дорогами и башнями, и прочими объектами
		 */
		private var _map:Array;
		/**
		 * матрица лабиринта
		 */ 
		private var _maze:Array;
		// матрица лабиринта для работы внутри класса
		private var mxMaze:Array; 
		// матрица построения волны 
		private var mxWave:Array; 
		
		// флаг удачного поиска пути
		private var _flFindSuccess:Boolean;
		
		/**
		 * массив ячеек пути прохождения лабиринта из точки А в точку B
		 */
		private var path:Vector.<Cell>;
		
		// индексы стартовой и финишной ячеек
		private var startRow:uint;
		private var startCol:uint;
		private var finishRow:uint;
		private var finishCol:uint;
		
		// переменная для поиска минимального пути
		private var min:Number;
		private var newCell:Cell;
		private var _scene:IsoScene = new IsoScene();
		
		/**
		 * Конструктор пути 
		 * Формирует путь движения персонажа по карте (лабиринте) посредством 
		 * поиска кратчайшего пути
		 * @param	n - ширина карты (лабиринта)
		 * @param	m - длина карты (лабиринта)
		 */
		public function MapManager(n:uint, m:uint) 
		{
			cntRow = n;
			cntCol = m;
			
			initMaze();
		}
		
		/** инициализация пустого лабиринта
		 */
		private function initMaze():void {
			mxMaze = new Array();
			for (var i:uint = 0; i < cntRow; i++) {
				mxMaze[i] = new Vector.<uint>();
				for (var j:uint = 0; j < cntCol; j++) {
					mxMaze[i][j] = CELL_WALL;
				}
			}
			_map = maze;
		}
		
		/**
		 * Инициализируем лабиринт проходами
		 * @param	road - массив ячеек проходов
		 */
		public function setMaze(road:Vector.<Cell>):void 
		{
			for (var i:uint = 0; i < road.length;i++ ){
				setRoadCell(road[i].row, road[i].col);
			}
		}
		
		/**
		 * Устанавливает данные лабиринта - проходимые ячейки, по которым можно двигаться
		 * @param	i - индекс ячейки по строке
		 * @param	j - индекс ячейки по столбцу
		 */
		public function setRoadCell(i:uint,j:uint):void {
			mxMaze[i][j] = CELL_ROAD;
			_map[i][j] = CELL_ROAD;
		}
		
		// инициализируем матрицу карты позициями башни (центральная и угловые ячейки)
		public function setTower(pos:Cell):void {
			var n:Number = Assets.TOWER_SIZE / 2;
			var m:Number = n - 1;
		
			// устанавливаем угловые ячейки башни в матрицу карты
			setTowerCell(new Cell(pos.row + m, pos.col + m));
			setTowerCell(new Cell(pos.row - n, pos.col - n));
			setTowerCell(new Cell(pos.row + m, pos.col - n));
			setTowerCell(new Cell(pos.row - n, pos.col + m));
		}
		
		/**
		 * Устанавливает ячейки, занятые башней
		 */
		public function setTowerCell(cell:Cell):void {
			if( (cell.row >= 0 && cell.col >= 0) && (cell.row < cntRow && cell.col < cntCol)){
				_map[cell.row][cell.col] = CELL_TOWER;
			}
		}
		
		/**
		 * Возвращает true, если ячейка на карте занята
		 * @return
		 */
		public function isMapCellBusy(cell:Cell):Boolean {
			var flCheck:Boolean;
			flCheck = cell.row < 0 || cell.col < 0;
			if(!flCheck){
				flCheck = (cell.row >= cntRow || cell.col >= cntCol);
				if(!flCheck){
					flCheck = _map[cell.row][cell.col] == CELL_ROAD || _map[cell.row][cell.col] == CELL_TOWER;
				}
			}
			
			return flCheck;
		}
		
		/**
		 * Инициализируем сцену для вывода карты с башнями и дорогами
		 */
		public function initScene():void {
			
			scene.removeAllChildren();
			
			var rect:IsoRectangle;
			
			for (var i:uint = 0; i < cntRow; i++){
				for (var j:uint = 0; j < cntCol; j++) {
					if(_map[i][j]!=CELL_WALL){
						rect = new IsoRectangle();
						rect.setSize(Grid.sizeTail, Grid.sizeTail, 0);
						rect.moveTo(i * Grid.sizeTail, j * Grid.sizeTail, 0);
						if(_map[i][j]==CELL_TOWER){
							rect.fill = new SolidColorFill(0xFF0000, 0.5);
						} else if (_map[i][j] == CELL_ROAD) {
							rect.fill = new SolidColorFill(0xa0522d, 0.5);	
						}
						
						scene.addChild(rect);
					}
				}
			}	
			
			scene.render();
		}
		
		/**
		 * Произвести поиск пути в лабиринте
		 * @param	start - стартовая позиция
		 * @param	finish - финишная позиция
		 * @return  true - если путь найден, false - иначе
		 */
		public function findPath(start:Cell, finish:Cell):Vector.<Cell> {
			
		 	startRow = start.row;
			startCol = start.col;
			
			finishRow = finish.row;
			finishCol = finish.col;
			
			mxMaze[startRow][startCol] = CELL_START;
			mxMaze[finishRow][finishCol] = CELL_FINISH;
			
			initWave();
			goSeach();
			initPath();
			
			return path;
		}
		
		//Инициализация матрицы для поиска пути
		private function initWave():void 
		{
			// делаем копию матрицы лабиринта для прохождения волны
			mxWave = maze;
			
			wi = 0;
			wk = (cntRow>cntCol?cntRow+20:cntCol+20);
			_flFindSuccess = false;
		}
		
		// поиск пути в лабиринте - запуск волны
		private function goSeach():Boolean {
			
			for (var i:uint = 0; i < cntRow; i++) {
				for (var j:uint = 0; j < cntRow; j++) {
					
					// начинаем проход от финиша к старту
					if (mxWave[i][j] == wi) {
						// просматриваем соседние ячейки
						if (i - 1 >= 0) { goWave(i - 1, j); }
						if (i - 1 >= 0 && j + 1 < cntCol) { goWave(i - 1, j + 1); }
						if (i - 1 >= 0 && j - 1 >= 0) { goWave(i - 1, j - 1); }
						if (i + 1 < cntRow) { goWave(i + 1, j); }
						if (i + 1 >= 0 && j + 1 < cntCol) { goWave(i + 1, j + 1); }
						if (i + 1 >= 0 && j - 1 >= 0) { goWave(i + 1, j - 1); }
						if (j - 1 >= 0) { goWave(i, j - 1); }
						if (j + 1 < cntCol) { goWave(i, j+1); }
					}
				}
			}
			
			// увеличиваем длину волны и проверяем предел итераций
			wi++;
			
			if (wi > wk) {
				_flFindSuccess = false;
			}
			
			// повторяем проход с текущей позиции
			if(!_flFindSuccess && wi <= wk) goSeach();
			
			return _flFindSuccess;
		}
		
		// прохождение волны в ячейке лабиринта (i,j)
		private function goWave(i:uint,j:uint):void {
			if (mxWave[i][j] == CELL_START) {
				// выход найден
				_flFindSuccess = true;
			} else if (mxWave[i][j] == CELL_ROAD) {
				// устанавливаем значение волны
				mxWave[i][j] = wi + 1;
				
			}
		}	
				
		// выборка минимальногоо пути - инициализация массива искомого пути
		private function initPath():void 
		{
			path = new Vector.<Cell>();
			
			//path.push(new Cell(startRow, startCol));
		
			if(_flFindSuccess) getCoordsMinWave(new Cell(startRow, startCol));
		}
		
		
		private function getCoordsMinWave(checkCell:Cell):void {
			
			min = CELL_WALL+1;
			
			path.push(checkCell);
			
			if (checkCell.row - 1 >= 0 ) { checkMin(checkCell.row - 1, checkCell.col); }
			if (checkCell.row - 1 >= 0 && checkCell.col + 1 < cntCol ) { checkMin(checkCell.row - 1, checkCell.col + 1); }	
			if (checkCell.row - 1 >= 0 && checkCell.col - 1 >= 0 ) { checkMin(checkCell.row - 1, checkCell.col - 1); }
			if (checkCell.row + 1 < cntRow ) { checkMin(checkCell.row + 1, checkCell.col); }			
			if (checkCell.row + 1 < cntRow && checkCell.col + 1 < cntCol ) { checkMin(checkCell.row + 1, checkCell.col + 1); }	
			if (checkCell.row + 1 < cntRow && checkCell.col - 1 >= 0 ) { checkMin(checkCell.row + 1, checkCell.col - 1); }
			if (checkCell.col - 1 >=0 ) { checkMin(checkCell.row, checkCell.col-1);}							
			if (checkCell.col + 1 < cntCol ) { checkMin(checkCell.row, checkCell.col+1);}
					
			if(!(newCell.row==finishRow && newCell.col==finishCol)){
				getCoordsMinWave(newCell);
			} 
		}
		
		// прохождение волны в ячейке лабиринта (i,j)
		private function checkMin(i:uint,j:uint):void {
			if(mxWave[i][j] < min){
				min = mxWave[i][j];
				newCell = new Cell(i, j);
			}
		}	
		
		/**
		 * Успешно ли найден путь
		 */
		public function get flFindSuccess():Boolean 
		{
			return _flFindSuccess;
		}
		
		public function get maze():Array 
		{
			var mxNew:Array = new Array();
			for (var i:uint = 0; i < cntRow; i++) {
				mxNew[i] = new Vector.<uint>();
				for (var j:uint = 0; j < cntCol; j++) {
					mxNew[i][j] = mxMaze[i][j];
				}
			}
			
			return mxNew;
		}
		
		public function get map():Array 
		{
			return _map;
		}
		
		public function get scene():IsoScene 
		{
			return _scene;
		}
		
	}

}