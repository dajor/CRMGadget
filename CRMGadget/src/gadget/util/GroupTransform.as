/* TILI:
 * Adaption to grouped activities. 
 * Bear in mind that I couldn't test it all that well and therefore it's a guess if this really works 
 * completely. Also, I really was in a hurry. 
 * This code must be revised at a later date, when the actual data to test it with is available. Synthetic data I 
 * specifically created for testing does, however, group itself. 
 */

package gadget.util {
import com.adobe.rtc.session.sessionClasses.GroupCollectionManager;

import flash.utils.Dictionary;

import gadget.dao.ActivityDAO;

import mx.collections.ArrayCollection;
import mx.collections.Grouping;
import mx.collections.GroupingCollection2;
import mx.collections.GroupingField;
import mx.controls.AdvancedDataGrid;

	public class GroupTransform {
		/* At a later date, the grouping field will be renamed to "ParentActivityId" (it's right now called
		 * "CustomText31" in the database).  */

		public static function transform(gridData:ArrayCollection):GroupingCollection2 {
			var gc:GroupingCollection2 = new GroupingCollection2();
			var grp:Grouping = new Grouping();
			grp.fields = [new GroupingField("ParentActivityId")];
			var parentIds:Object = new Object();
			var records:ArrayCollection = new ArrayCollection();
			var entry:Object;
			var hierarchies:int = 0;

			var cache:Object = new Object();
			/* right now, we traverse all gridData, passed along to the ADG. 
			 * All records having CustomText31 (or, later, ParentActivityId) are stored in another object such that
			 * cache["text"] is an array containing all children carrying that ParentActivityId.
			 */
			for each (entry in gridData) {
				// remove following line when DB really contains ParentActivityId
				entry.ParentActivityId = entry.CustomText31;

				if (entry.ParentActivityId) {
					if (parentIds[entry.ParentActivityId] == undefined) {
						parentIds[entry.ParentActivityId] = new ArrayCollection();
						hierarchies++;
					}

					(parentIds[entry.ParentActivityId] as ArrayCollection).addItem(entry);
				}

				// Also, cache a mapping from Id to Entry while we're at it.	
				cache[entry.ActivityId] = entry;
			}

			// test if there really is a hierachy and return null if not
			if (hierarchies == 0) {
				return null;
			}

			// begin build of return records; first collect activities without children
			for each (entry in gridData) {
				if ((parentIds[entry.ActivityId] == undefined) && (entry.ParentActivityId == null)) {
					entry.ParentActivityId = "Activities";
					records.addItem(entry);
				}
			}

			/* run through the parent ids and create objects that carry the parent's subject
			* with the list of children as "children"-array. */
			for (entry in parentIds) {
				var o:Object = new Object();

				if (cache[entry]) {
					o = cache[entry];
				}

				o.ParentActivityId = "Activities";
				o.children = parentIds[entry];

				records.addItem(o);
			}

			gc.grouping = grp;
			gc.source = records;
			gc.refresh();

			return gc;
		}
	}
}	