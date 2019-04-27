package gadget.util
{
	import mx.charts.BarChart;
	import mx.charts.CategoryAxis;
	import mx.charts.ColumnChart;
	import mx.charts.Legend;
	import mx.charts.PieChart;
	import mx.charts.chartClasses.Series;
	import mx.charts.series.BarSeries;
	import mx.charts.series.ColumnSeries;
	import mx.charts.series.PieSeries;
	import mx.containers.HBox;
	import mx.core.UIComponent;

	public class ChartUtils
	{
		
		public static const PIE_CHART:String = "1";
		public static const COLUMN_CHART:String = "2";
		public static const BAR_CHART:String = "3";
		
		public function ChartUtils()
		{
		}
		
		/**
		 * 
		 * @param data object { field, nameField, records }
		 * @return PieChart3D
		 * 
		 */
		private static function createPieChart(data:Object):PieChart {
			
			/* Define pie series. */
			var series:PieSeries = new PieSeries();
			series.nameField = data.nameField;
			series.field = data.field;
			
			/* set label position */						
			series.setStyle("labelPosition","inside"); // inside, callout, insideWithCallout, outside, none
			
			series.filters =[];
			/* Define pie chart. */
			var chart:PieChart = new PieChart();
			chart.showDataTips = true;
			chart.dataProvider = data.records;
			chart.series = [series];
			
			return chart;
		}
		
		
		private static function buildSeries(categoryField:String, xField:String, yFields:Array, horiz:Boolean):Array {
			
			var ret:Array = [];
			
			for each(var column:String in yFields) {
				
				var series:Series = horiz ? new BarSeries() : new ColumnSeries();
				
				series.displayName = column;
				series["xField"] = horiz ? column : xField;
				series["yField"] = horiz ? xField : column;
				
				series.filters=[];
				ret.push(series);
			}
			
			return ret;
			
		}
		
		
		
		/**
		 * 
		 * @param data { categoryField, xField, yField, records }
		 * @return ColumnChart3D
		 * 
		 */
		private static function createColumnChart(data:Object):ColumnChart {                   	
			
			/* Define column chart. */
			var chart:ColumnChart = new ColumnChart();  
			chart.showDataTips = true;
			chart.dataProvider = data.records;
			chart.series = buildSeries(data.categoryField, data.xField, data.yField, false);
			
			var cat:CategoryAxis = new CategoryAxis();
			cat.categoryField = data.categoryField;
			chart.horizontalAxis = cat;
			
			return chart;
		}
		
		/**
		 * 
		 * @param data { categoryField, xField, yField, records }
		 * @return BarChart3D
		 * 
		 */
		private static function createBarChart(data:Object):BarChart {                             	
			
			/* Define bar chart. */                
			var chart:BarChart = new BarChart();            
			
			chart.showDataTips = true;
			chart.dataProvider = data.records;
			chart.series = buildSeries(data.categoryField, data.xField, data.yField, true);
			var cat:CategoryAxis = new CategoryAxis();
			cat.categoryField = data.categoryField;
			chart.verticalAxis = cat;
			
			return chart;
		}		
		
		/**
		 * 
		 * @param data
		 * @param chartType
		 * @param chart3D
		 * @return 
		 * 
		 */
		public static function createChart(data:Object, chartType:String):UIComponent {
			
			var chart:UIComponent = null;
			var chartPercentH:Number = 100;
			var hBox:HBox = new HBox();
			hBox.setStyle("verticalAlign", "middle");
			hBox.percentWidth = 100;
			hBox.percentHeight = 100;
			
			switch (chartType) {
				case PIE_CHART:
					chart = createPieChart(data);
					chartPercentH = 70;
					break;
				case COLUMN_CHART:
					chart = createColumnChart(data);
					break;
				case BAR_CHART:
					chart = createBarChart(data);						
					break;
			}
			chart.percentWidth = 100;
			chart.percentHeight = chartPercentH;
			
			var legend:Legend = new Legend();
			legend.dataProvider = chart;
			
			hBox.addChild(chart);
			hBox.addChild(legend);
			
			return hBox;
		}
		
	}
}