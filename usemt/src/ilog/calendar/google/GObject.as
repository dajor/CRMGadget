package ilog.calendar.google
{
  use namespace atom;
  use namespace gCal;
  use namespace gd;
  use namespace atom;  
  
  /**
   * Base class of a wrapper of a Google XML data object.
   */   
  public class GObject
  {
    private var _data:XML;
    
    /**
     * Constructor.
     * 
     * @param data The data object to wrap.
     */  
    public function GObject(data:XML=null) {
      _data = data;
      
      if (_data == null) {
        _data = createDefaultData();
      }
    }
    
    /**
     * The wrapped XML data.
     */  
    public function set data(value:XML):void {
      _data = value;
    }
    
    /**
     * @private
     */  
    public function get data():XML {
      return _data
    }
    
    protected function createDefaultData():XML {
      return null;
    }
    
    /**
     * The alternate link of this object.
     */   
    public function get linkAlternate():String {
      if (data == null) {
        return null;
      }      
      return data.link.(@rel == "alternate").@href;
    }
    
    /**
     * The self link of this object.
     */
    public function get linkSelf():String {
      if (data == null) {
        return null;
      }      
      return data.link.(@rel == "self").@href;
    }
    
    /**
     * The edit link of this object.
     */
    public function get linkEdit():String {
      if (data == null) {
        return null;
      }      
      return data.link.(@rel == "edit").@href;
    }

  }
}