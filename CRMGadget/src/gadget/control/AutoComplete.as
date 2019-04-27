////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package gadget.control
{
	import com.flextras.autoCompleteComboBox.AutoCompleteComboBox;

public class AutoComplete extends AutoCompleteComboBox 
{
	
	private var _updateRelateFieldOnSelected:Function;

	//--------------------------------------------------------------------------
	//
	//  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
	public function AutoComplete()
	{
	    super();
		//this.autoCompleteRemoteData=true;
		autoCompleteEnabled=true;
		autoCompleteSelectOnEnter=true;
		this.autoCompleteCursorLocationOnSelect=false;
		//initialize();
		//initialized=true;
	
		
	  
	}


	
	override public function set selectedItem(value:Object):void
	{						
		
		super.selectedItem = value;
		if(updateRelateFieldOnSelected!=null){
			updateRelateFieldOnSelected(value);
		}
		
	}
	
	override public function get selectedItem():Object
	{
		return super.selectedItem;
	}
	

   
	

	public function get updateRelateFieldOnSelected():Function
	{
		return _updateRelateFieldOnSelected;
	}

	public function set updateRelateFieldOnSelected(value:Function):void
	{
		_updateRelateFieldOnSelected = value;
	}

}	
}
