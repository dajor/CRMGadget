package gadget.assessment
{
	import com.assessment.DtoColumn;
	import com.assessment.DtoConfiguration;

	public interface IAssessmentTotal
	{
		function getPercentTotal(col:DtoColumn):Number;
		function getAverageTotal():Number;
		function saveTotalToObject(item:Object):void;
		function getName():String;
		function getMapTotalField():String;
		function getModel():DtoConfiguration;
	}
}