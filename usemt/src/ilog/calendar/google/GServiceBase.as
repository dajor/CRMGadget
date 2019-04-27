package ilog.calendar.google
{
  import flash.events.EventDispatcher;
  import flash.events.IEventDispatcher;
  import flash.net.URLLoader;
  import flash.utils.Dictionary;

  /**
   * The base class of services. 
   */  
  public class GServiceBase extends EventDispatcher
  {
    public function GServiceBase(target:IEventDispatcher=null)
    {
      super(target);
    }
    
    private var _loaderMap:Dictionary = new Dictionary(true);
    
    /**
     * @private
     */ 
    protected function registerLoader(loader:URLLoader, data:Object):void {
      _loaderMap[loader] = data;
    }
    
    /**
     * @private
     */
    protected function retrieveData(loader:URLLoader):Object {
      return _loaderMap[loader];
    }
    
    /**
     * @private
     */
    protected function clearLoaderData(loader:URLLoader):void {
      delete _loaderMap[loader];
    }
    
  }
}