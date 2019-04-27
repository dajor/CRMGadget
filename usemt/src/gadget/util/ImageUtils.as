package gadget.util{
	import flash.utils.ByteArray;
	
	import gadget.dao.CustomRecordTypeServiceDAO;
	import gadget.dao.Database;
	import gadget.dao.PreferencesDAO;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.utils.Base64Decoder;

	public class ImageUtils{
		[Embed(source='/assets/resize.png')] [Bindable] public static var resize:Class;
		[Embed(source='/assets/customize.png')] [Bindable] public static var customIcon:Class;
		[Embed(source='/assets/appointment.png')] [Bindable] public static var appointmentIcon:Class;
		[Embed(source='/assets/d_silhouette.gif')] [Bindable] public static var noPhoto:Class;
		[Embed(source='/assets/feed/add_group.png')] [Bindable] public static var addGroup:Class;
		[Embed(source='/assets/feed/add_member.png')] [Bindable] public static var addMember:Class;
		[Embed(source='/assets/feed/remove_group.png')] [Bindable] public static var removeGroup:Class;
		[Embed(source='/assets/feed/remove_member.png')] [Bindable] public static var removeMember:Class;
		[Embed(source='/assets/feed/group.png')] [Bindable] public static var group:Class;
		[Embed(source='/assets/feed/member.png')] [Bindable] public static var member:Class;
		
		[Embed(source='/assets/daily_agenda.png')] [Bindable] public static var dailyAgenda:Class;
		[Embed(source='/assets/chat_icon.png')] [Bindable] public static var chat:Class;
		[Embed(source='/assets/chart_Bar.png')] [Bindable] public static var chartBar:Class;
		[Embed(source='/assets/darkCross.png')] [Bindable] public static var darkCross:Class;
		[Embed(source='/assets/facebook.png')] [Bindable] public static var facebookIcon:Class;
		[Embed(source='/assets/linkedin.png')] [Bindable] public static var linkedinIcon:Class;
		[Embed(source='/assets/cross.png')] [Bindable] public static var cross:Class;
		[Embed(source='/assets/time.png')] [Bindable] public static var time:Class;
		[Embed(source='/assets/paper.png')] [Bindable] public static var paper:Class;
		[Embed(source='/assets/favorite.png')] [Bindable] public static var favorite:Class;
		[Embed(source='/assets/unfavorite.png')] [Bindable] public static var unFavorite:Class;
		[Embed(source='/assets/gcalendar-16.png')] [Bindable] public static var gCalendarIcon:Class;
		[Embed(source='/assets/custom/si_contacts16_p.gif')] [Bindable] public static var pContactDefaultIcon:Class;
		[Embed(source='/assets/contact_p.png')] [Bindable] public static var pContactIcon:Class;
		[Embed(source='/assets/epadSign.png')] [Bindable] public static var epadSignIcon:Class;
		[Embed(source='/assets/epadSignPre.png')] [Bindable] public static var epadSignPreIcon:Class;
		[Embed(source='/assets/Formula.png')] [Bindable] public static var formulaIcon:Class;
		[Embed(source='/assets/custom_field.png')] [Bindable] public static var customFieldIcon:Class;
		[Embed(source='/assets/field.png')] [Bindable] public static var fieldIcon:Class;
		[Embed(source='/assets/excel.gif')] [Bindable] public static var excelIcon:Class;
		[Embed(source='/assets/pdficon.gif')] [Bindable] public static var pdfIcon:Class;
		[Embed(source='/assets/warning.png')] [Bindable] public static var warningIcon:Class;
		[Embed(source='/assets/tick.png')] [Bindable] public static var tickIcon:Class;
		[Embed(source='/assets/cross.png')] [Bindable] public static var crossIcon:Class;
		[Embed(source='/assets/report.png')] [Bindable] public static var reportIcon:Class;
		[Embed(source='/assets/kitchen_report.png')] [Bindable] public static var kitchenReportIcon:Class;
		[Embed(source='/assets/run_report.png')] [Bindable] public static var runReportIcon:Class;
		
		[Embed(source='/assets/info.png')] [Bindable] public static var infoIcon:Class;
		[Embed(source='/assets/error.png')] [Bindable] public static var errorIcon:Class;
		
		[Embed(source='/assets/mail_icon.png')] [Bindable] public static var emailIcon:Class;
		
		[Embed(source='/assets/next.png')] [Bindable] public static var nextDayIcon:Class;
		[Embed(source='/assets/previous.png')] [Bindable] public static var previousDayIcon:Class;
		
		[Embed(source='/assets/website.png')] [Bindable] public static var websiteIcon:Class;
		
		[Embed(source='/assets/sqlquery.png')] [Bindable] public static var sqlListImg:Class;
		[Embed(source='/assets/sqlfield.png')] [Bindable] public static var sqlFieldImg:Class;
		[Embed(source='/assets/htmlfield.png')] [Bindable] public static var htmlFieldImg:Class;
		[Embed(source='/assets/newsfield.png')] [Bindable] public static var newsFieldImg:Class;
		
		[Embed(source='/assets/lock.png')] [Bindable] public static var lockImg:Class;
		[Embed(source='/assets/mandatory.png')] [Bindable] public static var mandatoryImg:Class;
		
		[Embed(source='/assets/business_plan.gif')] [Bindable] private static var businessPlanImg:Class;
		[Embed(source='/assets/territory.png')] [Bindable] private static var territoryImg:Class;
		[Embed(source='/assets/account.png')] [Bindable] private static var accountImg:Class;
		[Embed(source='/assets/asset.png')] [Bindable] private static var assetImg:Class;
		[Embed(source='/assets/contact.png')] [Bindable] private static var contactImg:Class;
        [Embed(source='/assets/opportunity.png')] [Bindable] private static var opportunityImg:Class;
        [Embed(source='/assets/activity.png')] [Bindable] private static var activityImg:Class;
        [Embed(source='/assets/service.png')] [Bindable] private static var serviceImg:Class;
        [Embed(source='/assets/product.png')] [Bindable] private static var productImg:Class;
		[Embed(source='/assets/campaign.png')] [Bindable] private static var campaignImg:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObjectImg:Class;
		[Embed(source='/assets/picklist.png')] [Bindable] private static var picklistImg:Class;
		[Embed(source='/assets/lead.png')] [Bindable] private static var leadImg:Class;
		[Embed(source='/assets/custom2.png')] [Bindable] private static var customObject2Img:Class;
		[Embed(source='/assets/custom3.png')] [Bindable] private static var customObject3Img:Class;
		[Embed(source='/assets/custom7.png')] [Bindable] private static var customObject7Img:Class;
		[Embed(source='/assets/custom14.png')] [Bindable] private static var customObject14Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject15Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject4Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject5Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject6Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject8Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject9Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject10Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject11Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject12Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject13Img:Class;
		[Embed(source='/assets/note.png')] [Bindable] private static var noteImg:Class;
		[Embed(source='/assets/meded.png')] [Bindable] private static var medEdImg:Class;
		
		[Embed(source='/assets/objective.gif')] [Bindable] private static var objectivesImg:Class;
		
		[Embed(source='/assets/account_bw.png')] [Bindable] private static var accountBWImg:Class;
		[Embed(source='/assets/asset_bw.png')] [Bindable] private static var assetBWImg:Class;
		[Embed(source='/assets/contact_bw.png')] [Bindable] private static var contactBWImg:Class;
		[Embed(source='/assets/opportunity_bw.png')] [Bindable] private static var opportunityBWImg:Class;
		[Embed(source='/assets/activity_bw.png')] [Bindable] private static var activityBWImg:Class;
		[Embed(source='/assets/service_bw.png')] [Bindable] private static var serviceBWImg:Class;
		[Embed(source='/assets/campaign_bw.png')] [Bindable] private static var campaignBWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var customBWImg:Class;
		[Embed(source='/assets/custom2_bw.png')] [Bindable] private static var custom2BWImg:Class;
		[Embed(source='/assets/custom3_bw.png')] [Bindable] private static var custom3BWImg:Class;
		[Embed(source='/assets/custom7_bw.png')] [Bindable] private static var custom7BWImg:Class;
		[Embed(source='/assets/custom14_bw.png')] [Bindable] private static var custom14BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom15BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom4BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom5BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom6BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom8BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom9BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom10BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom11BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom12BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom13BWImg:Class;
		[Embed(source='/assets/lead_bw.png')] [Bindable] private static var leadBWImg:Class;
		[Embed(source='/assets/product_bw.png')] [Bindable] private static var productBWImg:Class;
		[Embed(source='/assets/note_bw.png')] [Bindable] private static var noteBWImg:Class;
		[Embed(source='/assets/meded_bw.png')] [Bindable] private static var medEdBWImg:Class;
		[Embed(source='/assets/objective.gif')] [Bindable] private static var objectivesBWImg:Class;
		
		[Embed(source='/assets/custom/si_account16.gif')] [Bindable] private static var accountDefaultImg:Class;
		[Embed(source='/assets/custom/si_asset16.gif')] [Bindable] private static var assetDefaultImg:Class;
		[Embed(source='/assets/custom/si_contacts16.gif')] [Bindable] private static var contactDefaultImg:Class;
		[Embed(source='/assets/custom/si_opportunities16.gif')] [Bindable] private static var opportunityDefaultImg:Class;
		[Embed(source='/assets/custom/si_task16.gif')] [Bindable] private static var activityTaskDefaultImg:Class;
		[Embed(source='/assets/custom/si_appointments16.gif')] [Bindable] private static var activityAppointmentDefaultImg:Class;
		[Embed(source='/assets/call.png')] [Bindable] private static var activityCallDefaultImg:Class;
		[Embed(source='/assets/custom/si_service16.gif')] [Bindable] private static var serviceDefaultImg:Class;
		[Embed(source='/assets/custom/si_product16.gif')] [Bindable] private static var productDefaultImg:Class;
		[Embed(source='/assets/custom/si_campaigns16.gif')] [Bindable] private static var campaignDefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObjectDefaultImg:Class;
		[Embed(source='/assets/custom/si_leads16.gif')] [Bindable] private static var leadDefaultImg:Class;		
		[Embed(source='/assets/custom/si_custobj2_16.gif')] [Bindable] private static var customObject2DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj3_16.gif')] [Bindable] private static var customObject3DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj7_16.gif')] [Bindable] private static var customObject7DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj14_16.gif')] [Bindable] private static var customObject14DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject15DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject4DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject5DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject6DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject8DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject9DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject10DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject11DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject12DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject13DefaultImg:Class;
		[Embed(source='/assets/custom/si_flag.png')] [Bindable] private static var flagBWImg:Class;
		[Embed(source='/assets/custom/si_note16.gif')] [Bindable] private static var noteDefaultImg:Class;
		[Embed(source='/assets/custom/si_meded16.gif')] [Bindable] private static var medEdDefaultImg:Class;
		[Embed(source='/assets/objective.gif')] [Bindable] private static var objectivesDefaultImg:Class;
		
		[Embed(source='/assets/custom/si_account16_bw.gif')] [Bindable] private static var accountDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_asset16_bw.gif')] [Bindable] private static var assetDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_contacts16_bw.gif')] [Bindable] private static var contactDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_opportunities16_bw.gif')] [Bindable] private static var opportunityDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_task16_bw.gif')] [Bindable] private static var activityTaskDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_appointments16_bw.gif')] [Bindable] private static var activityAppointmentDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_service16_bw.gif')] [Bindable] private static var serviceDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_product16_bw.gif')] [Bindable] private static var productDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_campaigns16_bw.gif')] [Bindable] private static var campaignDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var customObjectDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_leads16_bw.gif')] [Bindable] private static var leadDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var customDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj2_16_bw.gif')] [Bindable] private static var custom2DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj3_16_bw.gif')] [Bindable] private static var custom3DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj7_16_bw.gif')] [Bindable] private static var custom7DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj14_16_bw.gif')] [Bindable] private static var custom14DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom15DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom4DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom5DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom6DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom8DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom9DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom10DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom11DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom12DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom13DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_note16_bw.gif')] [Bindable] private static var noteDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_meded16_bw.gif')] [Bindable] private static var medEdDefaultBWImg:Class;
		[Embed(source='/assets/objective.gif')] [Bindable] private static var objectivesDefaultBWImg:Class;
		
		[Embed(source='/assets/custom/oracleicons/1006.gif')] [Bindable] private static var icon_1006:Class;
		[Embed(source='/assets/custom/oracleicons/1033.gif')] [Bindable] private static var icon_1033:Class;
		[Embed(source='/assets/custom/oracleicons/1048.gif')] [Bindable] private static var icon_1048:Class;
		[Embed(source='/assets/custom/oracleicons/1056.gif')] [Bindable] private static var icon_1056:Class;
		[Embed(source='/assets/custom/oracleicons/1801.gif')] [Bindable] private static var icon_1801:Class;
		[Embed(source='/assets/custom/oracleicons/1824.gif')] [Bindable] private static var icon_1824:Class;
		[Embed(source='/assets/custom/oracleicons/1826.gif')] [Bindable] private static var icon_1826:Class;
		
		[Embed(source='/assets/custom/oracleicons/16_account.png')] [Bindable] private static var icon_16_account:Class;
		[Embed(source='/assets/custom/oracleicons/16_accountPDQPinned.png')] [Bindable] private static var icon_16_accountPDQPinned:Class;
		[Embed(source='/assets/custom/oracleicons/16_accounts.png')] [Bindable] private static var icon_16_accounts:Class;
		[Embed(source='/assets/custom/oracleicons/16_account_contact.png')] [Bindable] private static var icon_16_account_contact:Class;
		[Embed(source='/assets/custom/oracleicons/16_addresses.png')] [Bindable] private static var icon_16_addresses:Class;
		[Embed(source='/assets/custom/oracleicons/16_alerts_grid.png')] [Bindable] private static var icon_16_alerts_grid:Class;
		[Embed(source='/assets/custom/oracleicons/16_analytics_grid.png')] [Bindable] private static var icon_16_analytics_grid:Class;
		[Embed(source='/assets/custom/oracleicons/16_aroundme_grid.png')] [Bindable] private static var icon_16_aroundme_grid:Class;
		[Embed(source='/assets/custom/oracleicons/16_bestCallTime.png')] [Bindable] private static var icon_16_bestCallTime:Class;
		[Embed(source='/assets/custom/oracleicons/16_calendar_grid.png')] [Bindable] private static var icon_16_calendar_grid:Class;
		[Embed(source='/assets/custom/oracleicons/16_callHistory.png')] [Bindable] private static var icon_16_callHistory:Class;
		[Embed(source='/assets/custom/oracleicons/16_callProductDetails.png')] [Bindable] private static var icon_16_callProductDetails:Class;
		[Embed(source='/assets/custom/oracleicons/16_contacts.png')] [Bindable] private static var icon_16_contacts:Class;
		[Embed(source='/assets/custom/oracleicons/16_contacts_grid.png')] [Bindable] private static var icon_16_contacts_grid:Class;
		[Embed(source='/assets/custom/oracleicons/16_generic_grid.png')] [Bindable] private static var icon_16_generic_grid:Class;
		[Embed(source='/assets/custom/oracleicons/16_gift.png')] [Bindable] private static var icon_16_gift:Class;
		[Embed(source='/assets/custom/oracleicons/16_launchDetailer.png')] [Bindable] private static var icon_16_launchDetailer:Class;
		[Embed(source='/assets/custom/oracleicons/16_launchPresentation.png')] [Bindable] private static var icon_16_launchPresentation:Class;
		[Embed(source='/assets/custom/oracleicons/16_leads_grid.png')] [Bindable] private static var icon_16_leads_grid:Class;
		[Embed(source='/assets/custom/oracleicons/16_licenses.png')] [Bindable] private static var icon_16_licenses:Class;
		[Embed(source='/assets/custom/oracleicons/16_opportunities_grid.png')] [Bindable] private static var icon_16_opportunities_grid:Class;
		[Embed(source='/assets/custom/oracleicons/16_presentationDetails.png')] [Bindable] private static var icon_16_presentationDetails:Class;
		[Embed(source='/assets/custom/oracleicons/16_relationships.png')] [Bindable] private static var icon_16_relationships:Class;
		[Embed(source='/assets/custom/oracleicons/16_sales_accounts_grid.png')] [Bindable] private static var icon_16_sales_accounts_grid:Class;
		[Embed(source='/assets/custom/oracleicons/16_sample.png')] [Bindable] private static var icon_16_sample:Class;
		[Embed(source='/assets/custom/oracleicons/16_samples.png')] [Bindable] private static var icon_16_samples:Class;
		[Embed(source='/assets/custom/oracleicons/16_tasks_grid.png')] [Bindable] private static var icon_16_tasks_grid:Class;
		[Embed(source='/assets/custom/oracleicons/application_form.png')] [Bindable] private static var icon_application_form:Class;
		[Embed(source='/assets/custom/oracleicons/application_view_tile.png')] [Bindable] private static var icon_application_view_tile:Class;
		[Embed(source='/assets/custom/oracleicons/arrow_divide.png')] [Bindable] private static var icon_arrow_divide:Class;
		[Embed(source='/assets/custom/oracleicons/asterisk_orange.png')] [Bindable] private static var icon_asterisk_orange:Class;
		[Embed(source='/assets/custom/oracleicons/attach.png')] [Bindable] private static var icon_attach:Class;
		[Embed(source='/assets/custom/oracleicons/award_star_gold_1.png')] [Bindable] private static var icon_award_star_gold_1:Class;
		[Embed(source='/assets/custom/oracleicons/bell.png')] [Bindable] private static var icon_bell:Class;
		[Embed(source='/assets/custom/oracleicons/box.png')] [Bindable] private static var icon_box:Class;
		[Embed(source='/assets/custom/oracleicons/brick.png')] [Bindable] private static var icon_brick:Class;
		[Embed(source='/assets/custom/oracleicons/bug.png')] [Bindable] private static var icon_bug:Class;
		[Embed(source='/assets/custom/oracleicons/building.png')] [Bindable] private static var icon_building:Class;
		[Embed(source='/assets/custom/oracleicons/cake.png')] [Bindable] private static var icon_cake:Class;
		[Embed(source='/assets/custom/oracleicons/camera.png')] [Bindable] private static var icon_camera:Class;
		[Embed(source='/assets/custom/oracleicons/campaign_status.gif')] [Bindable] private static var icon_campaign_status:Class;
		[Embed(source='/assets/custom/oracleicons/car.png')] [Bindable] private static var icon_car:Class;
		[Embed(source='/assets/custom/oracleicons/cart.png')] [Bindable] private static var icon_cart:Class;
		[Embed(source='/assets/custom/oracleicons/catalog_status.gif')] [Bindable] private static var icon_catalog_status:Class;
		[Embed(source='/assets/custom/oracleicons/certificaterequired.gif')] [Bindable] private static var icon_certificaterequired:Class;
		[Embed(source='/assets/custom/oracleicons/chart_bar.png')] [Bindable] private static var icon_chart_bar:Class;
		[Embed(source='/assets/custom/oracleicons/chart_organisation.png')] [Bindable] private static var icon_chart_organisation:Class;
		[Embed(source='/assets/custom/oracleicons/chart_pie.png')] [Bindable] private static var icon_chart_pie:Class;
		[Embed(source='/assets/custom/oracleicons/clock.png')] [Bindable] private static var icon_clock:Class;
		[Embed(source='/assets/custom/oracleicons/cog.png')] [Bindable] private static var icon_cog:Class;
		[Embed(source='/assets/custom/oracleicons/coins.png')] [Bindable] private static var icon_coins:Class;
		[Embed(source='/assets/custom/oracleicons/commentind_active.gif')] [Bindable] private static var icon_commentind_active:Class;
		[Embed(source='/assets/custom/oracleicons/controller.png')] [Bindable] private static var icon_controller:Class;
		[Embed(source='/assets/custom/oracleicons/cup.png')] [Bindable] private static var icon_cup:Class;
		[Embed(source='/assets/custom/oracleicons/derived_bidi_status.gif')] [Bindable] private static var icon_derived_bidi_status:Class;
		[Embed(source='/assets/custom/oracleicons/disconnect.png')] [Bindable] private static var icon_disconnect:Class;
		[Embed(source='/assets/custom/oracleicons/drive_network.png')] [Bindable] private static var icon_drive_network:Class;
		[Embed(source='/assets/custom/oracleicons/email.png')] [Bindable] private static var icon_email:Class;
		[Embed(source='/assets/custom/oracleicons/eye.png')] [Bindable] private static var icon_eye:Class;
		[Embed(source='/assets/custom/oracleicons/feed_icon.gif')] [Bindable] private static var icon_feed_icon:Class;
		[Embed(source='/assets/custom/oracleicons/female.png')] [Bindable] private static var icon_female:Class;
		[Embed(source='/assets/custom/oracleicons/film.png')] [Bindable] private static var icon_film:Class;
		[Embed(source='/assets/custom/oracleicons/flag_green.png')] [Bindable] private static var icon_flag_green:Class;
		[Embed(source='/assets/custom/oracleicons/heart.png')] [Bindable] private static var icon_heart:Class;
		[Embed(source='/assets/custom/oracleicons/house.png')] [Bindable] private static var icon_house:Class;
		[Embed(source='/assets/custom/oracleicons/HR_IMAGE5_184.gif')] [Bindable] private static var icon_HR_IMAGE5_184:Class;
		[Embed(source='/assets/custom/oracleicons/HR_IMAGE5_221.gif')] [Bindable] private static var icon_HR_IMAGE5_221:Class;
		[Embed(source='/assets/custom/oracleicons/HR_IMAGE5_249.gif')] [Bindable] private static var icon_HR_IMAGE5_249:Class;
		[Embed(source='/assets/custom/oracleicons/HR_IMAGE5_593.gif')] [Bindable] private static var icon_HR_IMAGE5_593:Class;
		[Embed(source='/assets/custom/oracleicons/HR_IMAGE5_678.gif')] [Bindable] private static var icon_HR_IMAGE5_678:Class;
		[Embed(source='/assets/custom/oracleicons/HR_IMAGE5_85.gif')] [Bindable] private static var icon_HR_IMAGE5_85:Class;
		[Embed(source='/assets/custom/oracleicons/icon_custtab.gif')] [Bindable] private static var icon_icon_custtab:Class;
		[Embed(source='/assets/custom/oracleicons/instore_status.gif')] [Bindable] private static var icon_instore_status:Class;
		[Embed(source='/assets/custom/oracleicons/ipod.png')] [Bindable] private static var icon_ipod:Class;
		[Embed(source='/assets/custom/oracleicons/key.png')] [Bindable] private static var icon_key:Class;
		[Embed(source='/assets/custom/oracleicons/lightbulb.png')] [Bindable] private static var icon_lightbulb:Class;
		[Embed(source='/assets/custom/oracleicons/lightning.png')] [Bindable] private static var icon_lightning:Class;
		[Embed(source='/assets/custom/oracleicons/locked_status.gif')] [Bindable] private static var icon_locked_status:Class;
		[Embed(source='/assets/custom/oracleicons/male.png')] [Bindable] private static var icon_male:Class;
		[Embed(source='/assets/custom/oracleicons/map.png')] [Bindable] private static var icon_map:Class;
		[Embed(source='/assets/custom/oracleicons/money.png')] [Bindable] private static var icon_money:Class;
		[Embed(source='/assets/custom/oracleicons/money_dollar.png')] [Bindable] private static var icon_money_dollar:Class;
		[Embed(source='/assets/custom/oracleicons/money_euro.png')] [Bindable] private static var icon_money_euro:Class;
		[Embed(source='/assets/custom/oracleicons/mouse.png')] [Bindable] private static var icon_mouse:Class;
		[Embed(source='/assets/custom/oracleicons/newupdateditem_status.gif')] [Bindable] private static var icon_newupdateditem_status:Class;
		[Embed(source='/assets/custom/oracleicons/onvacation_status.gif')] [Bindable] private static var icon_onvacation_status:Class;
		[Embed(source='/assets/custom/oracleicons/orders_icon.gif')] [Bindable] private static var icon_orders_icon:Class;
		[Embed(source='/assets/custom/oracleicons/package_green.png')] [Bindable] private static var icon_package_green:Class;
		[Embed(source='/assets/custom/oracleicons/paintcan.png')] [Bindable] private static var icon_paintcan:Class;
		[Embed(source='/assets/custom/oracleicons/palette.png')] [Bindable] private static var icon_palette:Class;
		[Embed(source='/assets/custom/oracleicons/phone.png')] [Bindable] private static var icon_phone:Class;
		[Embed(source='/assets/custom/oracleicons/photo.png')] [Bindable] private static var icon_photo:Class;
		[Embed(source='/assets/custom/oracleicons/plugin.png')] [Bindable] private static var icon_plugin:Class;
		[Embed(source='/assets/custom/oracleicons/primary_status.gif')] [Bindable] private static var icon_primary_status:Class;
		[Embed(source='/assets/custom/oracleicons/printer.png')] [Bindable] private static var icon_printer:Class;
		[Embed(source='/assets/custom/oracleicons/quotes_icon.gif')] [Bindable] private static var icon_quotes_icon:Class;
		[Embed(source='/assets/custom/oracleicons/rainbow.png')] [Bindable] private static var icon_rainbow:Class;
		[Embed(source='/assets/custom/oracleicons/register_status.gif')] [Bindable] private static var icon_register_status:Class;
		[Embed(source='/assets/custom/oracleicons/rosette.png')] [Bindable] private static var icon_rosette:Class;
		[Embed(source='/assets/custom/oracleicons/rte_image_enabled.gif')] [Bindable] private static var icon_rte_image_enabled:Class;
		[Embed(source='/assets/custom/oracleicons/rte_paste_enabled.gif')] [Bindable] private static var icon_rte_paste_enabled:Class;
		[Embed(source='/assets/custom/oracleicons/ruby.png')] [Bindable] private static var icon_ruby:Class;
		[Embed(source='/assets/custom/oracleicons/shield.png')] [Bindable] private static var icon_shield:Class;
		[Embed(source='/assets/custom/oracleicons/sound.png')] [Bindable] private static var icon_sound:Class;
		[Embed(source='/assets/custom/oracleicons/sport_football.png')] [Bindable] private static var icon_sport_football:Class;
		[Embed(source='/assets/custom/oracleicons/sport_soccer.png')] [Bindable] private static var icon_sport_soccer:Class;
		[Embed(source='/assets/custom/oracleicons/telephone.png')] [Bindable] private static var icon_telephone:Class;
		[Embed(source='/assets/custom/oracleicons/television.png')] [Bindable] private static var icon_television:Class;
		[Embed(source='/assets/custom/oracleicons/timeexpires_status.gif')] [Bindable] private static var icon_timeexpires_status:Class;
		[Embed(source='/assets/custom/oracleicons/transmit.png')] [Bindable] private static var icon_transmit:Class;
		[Embed(source='/assets/custom/oracleicons/tree_alert.gif')] [Bindable] private static var icon_tree_alert:Class;
		[Embed(source='/assets/custom/oracleicons/tree_collateral.gif')] [Bindable] private static var icon_tree_collateral:Class;
		[Embed(source='/assets/custom/oracleicons/tree_component.gif')] [Bindable] private static var icon_tree_component:Class;
		[Embed(source='/assets/custom/oracleicons/tree_configextension.gif')] [Bindable] private static var icon_tree_configextension:Class;
		[Embed(source='/assets/custom/oracleicons/tree_contentobject.gif')] [Bindable] private static var icon_tree_contentobject:Class;
		[Embed(source='/assets/custom/oracleicons/tree_database.gif')] [Bindable] private static var icon_tree_database:Class;
		[Embed(source='/assets/custom/oracleicons/tree_forum.gif')] [Bindable] private static var icon_tree_forum:Class;
		[Embed(source='/assets/custom/oracleicons/tree_grades.gif')] [Bindable] private static var icon_tree_grades:Class;
		[Embed(source='/assets/custom/oracleicons/tree_graph.gif')] [Bindable] private static var icon_tree_graph:Class;
		[Embed(source='/assets/custom/oracleicons/tree_library.gif')] [Bindable] private static var icon_tree_library:Class;
		[Embed(source='/assets/custom/oracleicons/tree_messages.gif')] [Bindable] private static var icon_tree_messages:Class;
		[Embed(source='/assets/custom/oracleicons/tree_property.gif')] [Bindable] private static var icon_tree_property:Class;
		[Embed(source='/assets/custom/oracleicons/tree_server.gif')] [Bindable] private static var icon_tree_server:Class;
		[Embed(source='/assets/custom/oracleicons/tree_servicerequest.gif')] [Bindable] private static var icon_tree_servicerequest:Class;
		[Embed(source='/assets/custom/oracleicons/tree_sharedobjects.gif')] [Bindable] private static var icon_tree_sharedobjects:Class;
		[Embed(source='/assets/custom/oracleicons/tree_site.gif')] [Bindable] private static var icon_tree_site:Class;
		[Embed(source='/assets/custom/oracleicons/tree_testobject.gif')] [Bindable] private static var icon_tree_testobject:Class;
		[Embed(source='/assets/custom/oracleicons/tree_workflow.gif')] [Bindable] private static var icon_tree_workflow:Class;
		[Embed(source='/assets/custom/oracleicons/tux.png')] [Bindable] private static var icon_tux:Class;
		[Embed(source='/assets/custom/oracleicons/user_gray.png')] [Bindable] private static var icon_user_gray:Class;
		[Embed(source='/assets/custom/oracleicons/user_orange.png')] [Bindable] private static var icon_user_orange:Class;
		[Embed(source='/assets/custom/oracleicons/wand.png')] [Bindable] private static var icon_wand:Class;
		[Embed(source='/assets/custom/oracleicons/weather_sun.png')] [Bindable] private static var icon_weather_sun:Class;
		[Embed(source='/assets/custom/oracleicons/webpage_status.gif')] [Bindable] private static var icon_webpage_status:Class;
		[Embed(source='/assets/custom/oracleicons/world.png')] [Bindable] private static var icon_world:Class;
		[Embed(source='/assets/custom/oracleicons/zoom.png')] [Bindable] private static var icon_zoom:Class;
		
		[Embed(source='/assets/account_big.png')] [Bindable] private static var accountBigImg:Class;
		[Embed(source='/assets/asset_big.png')] [Bindable] private static var assetBigImg:Class;
		[Embed(source='/assets/contact_big.png')] [Bindable] private static var contactBigImg:Class;
        [Embed(source='/assets/opportunity_big.png')] [Bindable] private static var opportunityBigImg:Class;
        [Embed(source='/assets/activity_big.png')] [Bindable] private static var activityBigImg:Class;
        [Embed(source='/assets/product_big.png')] [Bindable] private static var productBigImg:Class;
        [Embed(source='/assets/service_big.png')] [Bindable] private static var serviceBigImg:Class;
		[Embed(source='/assets/campaign_big.png')] [Bindable] private static var campaignBigImg:Class;
		[Embed(source='/assets/custom_big.png')] [Bindable] private static var customBigImg:Class;
		[Embed(source='/assets/lead_big.png')] [Bindable] private static var leadBigImg:Class;
		[Embed(source='/assets/custom2_big.png')] [Bindable] private static var custom2BigImg:Class;
		[Embed(source='/assets/custom3_big.png')] [Bindable] private static var custom3BigImg:Class;
		[Embed(source='/assets/custom7_big.png')] [Bindable] private static var custom7BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom14BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom4BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom5BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom6BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom8BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom9BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom10BigImg:Class;
		[Embed(source='/assets/note_big.png')] [Bindable] private static var noteBigImg:Class;
		[Embed(source='/assets/meded_big.png')] [Bindable] private static var medEdBigImg:Class;
		
		[Embed(source='/assets/custom/bigicons/si_account80.gif')] [Bindable] private static var accountDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_asset80.gif')] [Bindable] private static var assetDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_contacts80.gif')] [Bindable] private static var contactDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_opportunities80.gif')] [Bindable] private static var opportunityDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_task80.gif')] [Bindable] private static var activityTaskDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_appointments80.gif')] [Bindable] private static var activityAppointmentDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_service80.gif')] [Bindable] private static var serviceDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_product80.gif')] [Bindable] private static var productDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_campaigns80.gif')] [Bindable] private static var campaignDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObjectDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_leads80.gif')] [Bindable] private static var leadDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj2_80.gif')] [Bindable] private static var customObject2DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj3_80.gif')] [Bindable] private static var customObject3DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj7_80.gif')] [Bindable] private static var customObject7DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj14_80.gif')] [Bindable] private static var customObject14DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObject4DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObject5DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObject6DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObject8DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObject9DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObject10DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_note80.gif')] [Bindable] private static var noteDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_meded80.gif')] [Bindable] private static var medEdDefaultBigImg:Class;
		
		[Embed("/assets/accept.png")] public static const acceptIcon:Class;
		[Embed("/assets/cancel.png")] public static const cancelIcon:Class;
		[Embed("/assets/edit.png")] public static const editIcon:Class;			
		[Embed("/assets/delete.png")] public static const deleteIcon:Class;
		[Embed("/assets/copy.png")] public static const copyIcon:Class;
		
		[Embed("/assets/add.png")] public static const addIcon:Class;
		[Embed("/assets/addBW.png")] public static const addBWIcon:Class;
		
		[Embed("/assets/link.png")] public static const linkIcon:Class;
		
		[Embed(source='/assets/triangle-left.gif')] [Bindable] public static var leftIcon:Class;
		[Embed(source='/assets/triangle-right.gif')] [Bindable] public static var rightIcon:Class;
		[Embed(source='/assets/triangle-down.gif')] [Bindable] public static var downIcon:Class;
		[Embed(source='/assets/triangle-up.gif')] [Bindable] public static var upIcon:Class;
		
		
		[Embed(source="/assets/sync.png")] [Bindable] public static var synIcon:Class;
		[Embed(source="/assets/sync_ok.png")] [Bindable] public static var synOkIcon:Class;
		[Embed(source="/assets/sync_error.png")] [Bindable] public static var synErrorIcon:Class;
		
		[Embed(source="/assets/custom/flag_blue.png")] [Bindable] public static var blueIcon:Class;
		[Embed(source="/assets/custom/flag_green.png")] [Bindable] public static var greenIcon:Class;
		[Embed(source="/assets/custom/flag_orange.png")] [Bindable] public static var orangeIcon:Class;
		[Embed(source="/assets/custom/flag_pink.png")] [Bindable] public static var pinkIcon:Class;
		[Embed(source="/assets/custom/flag_purple.png")] [Bindable] public static var purpleIcon:Class;
		[Embed(source="/assets/custom/flag_red.png")] [Bindable] public static var redIcon:Class;
		[Embed(source="/assets/custom/flag_yellow.png")] [Bindable] public static var yellowIcon:Class;
		[Embed(source='/assets/preview.gif')] [Bindable] public static var previewIcon:Class;
		[Embed(source='/assets/man.png')] [Bindable] public static var manIcon:Class;
		[Embed(source='/assets/woman.png')] [Bindable] public static var womanIcon:Class;
		[Embed(source='/assets/doctor.png')] [Bindable] public static var doctorIcon:Class;
		
		[Embed(source='/assets/red.gif')] [Bindable] public static var red:Class;
		[Embed(source='/assets/green.gif')] [Bindable] public static var green:Class;
		[Embed(source='/assets/yellow.gif')] [Bindable] public static var yellow:Class;
		[Embed(source='/assets/blue.gif')] [Bindable] public static var blue:Class;
		[Embed(source='/assets/orange.gif')] [Bindable] public static var orange:Class;
		[Embed(source='/assets/purple.gif')] [Bindable] public static var purple:Class;
		[Embed(source='/assets/gray.gif')] [Bindable] public static var gray:Class;
		[Embed(source='/assets/white.gif')] [Bindable] public static var white:Class;
		[Embed(source='/assets/black.gif')] [Bindable] public static var black:Class;
		[Embed(source='/assets/thumb.gif')] [Bindable] public static var thumb:Class;
		[Embed(source='/assets/tick.gif')] [Bindable] public static var tick:Class;
		[Embed(source='/assets/question.gif')] [Bindable] public static var question:Class;
		[Embed(source='/assets/warning.gif')] [Bindable] public static var warning:Class;
		[Embed(source='/assets/home.png')] [Bindable] public static var home:Class;
		
		[Embed(source='/assets/dark_blue.png')] [Bindable] public static var darkBlue:Class;
		[Embed(source='/assets/light_blue.png')] [Bindable] public static var lightBlue:Class;
		[Embed(source='/assets/light_green.png')] [Bindable] public static var lightGreen:Class;
		
		[Embed(source='/assets/TRiggmat_header_pic.png')] [Bindable] public static var triggmatHeaderPic:Class;
		[Embed(source='/assets/Miljö_header_pic.png')] [Bindable] public static var Miljo_header_pic:Class;
		
		
		//--- modern icons
		[Embed(source='/assets/custom/oracleModernIcons/mod_account_25.png')] [Bindable] private static var mod_account_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_account_25Big.png')] [Bindable] private static var mod_account_25Big:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_account_25_001.png')] [Bindable] private static var mod_account_25_001:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_accountpartners_25.png')] [Bindable] private static var mod_accountpartners_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_accreditation_25.png')] [Bindable] private static var mod_accreditation_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_accreditationrequest_25.png')] [Bindable] private static var mod_accreditationrequest_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_address_25.png')] [Bindable] private static var mod_address_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_allocation_25.png')] [Bindable] private static var mod_allocation_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_application_25.png')] [Bindable] private static var mod_application_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_assets_25.png')] [Bindable] private static var mod_assets_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_assets_25Big.png')] [Bindable] private static var mod_assets_25Big:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_attachment_25.png')] [Bindable] private static var mod_attachment_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_availableproductsfordetailing_25.png')] [Bindable] private static var mod_availableproductsfordetailing_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_blockedproduct_25.png')] [Bindable] private static var mod_blockedproduct_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_books_25.png')] [Bindable] private static var mod_books_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_brokerprofile_25.png')] [Bindable] private static var mod_brokerprofile_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_businessplan_25.png')] [Bindable] private static var mod_businessplan_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_calendar_25.png')] [Bindable] private static var mod_calendar_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_calendar_25Big.png')] [Bindable] private static var mod_calendar_25Big:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_callactivityhistory_25.png')] [Bindable] private static var mod_callactivityhistory_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_calls_25.png')] [Bindable] private static var mod_calls_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_campaign_25.png')] [Bindable] private static var mod_campaign_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_campaign_25Big.png')] [Bindable] private static var mod_campaign_25Big:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_category_25.png')] [Bindable] private static var mod_category_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_certification_25.png')] [Bindable] private static var mod_certification_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_certificationrequest_25.png')] [Bindable] private static var mod_certificationrequest_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_claim_25.png')] [Bindable] private static var mod_claim_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_communications_25.png')] [Bindable] private static var mod_communications_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_competitors_25.png')] [Bindable] private static var mod_competitors_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_contact_25.png')] [Bindable] private static var mod_contact_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_contactbesttime_25.png')] [Bindable] private static var mod_contactbesttime_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_contactbesttime_25Big.png')] [Bindable] private static var mod_contactbesttime_25Big:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_contact_25Big.png')] [Bindable] private static var mod_contact_25Big:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_contactstatelicense_25.png')] [Bindable] private static var mod_contactstatelicense_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_course_25.png')] [Bindable] private static var mod_course_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_courseenrollment_25.png')] [Bindable] private static var mod_courseenrollment_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_coverage_25.png')] [Bindable] private static var mod_coverage_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_customobject_25.png')] [Bindable] private static var mod_customobject_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_customobject_25Big.png')] [Bindable] private static var mod_customobject_25Big:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_customwebtab_25.png')] [Bindable] private static var mod_customwebtab_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_damage_25.png')] [Bindable] private static var mod_damage_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_dashboard_25.png')] [Bindable] private static var mod_dashboard_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_dealer_25.png')] [Bindable] private static var mod_dealer_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_dealregistration_25.png')] [Bindable] private static var mod_dealregistration_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_dealregistrationproductrevenue_25.png')] [Bindable] private static var mod_dealregistrationproductrevenue_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_directory_25.png')] [Bindable] private static var mod_directory_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_division_25.png')] [Bindable] private static var mod_division_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_event_25.png')] [Bindable] private static var mod_event_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_exam_25.png')] [Bindable] private static var mod_exam_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_exam_registration_25.png')] [Bindable] private static var mod_exam_registration_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_financialaccount_25.png')] [Bindable] private static var mod_financialaccount_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_financialaccountholder_25.png')] [Bindable] private static var mod_financialaccountholder_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_financialaccountholding_25.png')] [Bindable] private static var mod_financialaccountholding_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_financialplan_25.png')] [Bindable] private static var mod_financialplan_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_financialproduct_25.png')] [Bindable] private static var mod_financialproduct_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_financialtransaction_25.png')] [Bindable] private static var mod_financialtransaction_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_forecast_25.png')] [Bindable] private static var mod_forecast_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_fund_25.png')] [Bindable] private static var mod_fund_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_fundcredit_25.png')] [Bindable] private static var mod_fundcredit_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_funddebit_25.png')] [Bindable] private static var mod_funddebit_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_fundrequest_25.png')] [Bindable] private static var mod_fundrequest_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_group_25.png')] [Bindable] private static var mod_group_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_hash_25.png')] [Bindable] private static var mod_hash_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_hcpcontactallocation_25.png')] [Bindable] private static var mod_hcpcontactallocation_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_home_25.png')] [Bindable] private static var mod_home_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_household_25.png')] [Bindable] private static var mod_household_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_insuranceproperty_25.png')] [Bindable] private static var mod_insuranceproperty_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_interests_25.png')] [Bindable] private static var mod_interests_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_inventoryauditreport_25.png')] [Bindable] private static var mod_inventoryauditreport_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_inventoryperiod_25.png')] [Bindable] private static var mod_inventoryperiod_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_involvedparty_25.png')] [Bindable] private static var mod_involvedparty_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_lead_25.png')] [Bindable] private static var mod_lead_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_lead_25Big.png')] [Bindable] private static var mod_lead_25Big:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_makes_25.png')] [Bindable] private static var mod_makes_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_map_25.png')] [Bindable] private static var mod_map_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_mdfrequest_25.png')] [Bindable] private static var mod_mdfrequest_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_messageresponse_25.png')] [Bindable] private static var mod_messageresponse_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_messagingplan_25.png')] [Bindable] private static var mod_messagingplan_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_messagingplanitem_25.png')] [Bindable] private static var mod_messagingplanitem_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_messagingplanitemrelations_25.png')] [Bindable] private static var mod_messagingplanitemrelations_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_modificationtracking_25.png')] [Bindable] private static var mod_modificationtracking_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_notes_25.png')] [Bindable] private static var mod_notes_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_objective_25.png')] [Bindable] private static var mod_objective_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_opportunity_25.png')] [Bindable] private static var mod_opportunity_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_opportunity_25Big.png')] [Bindable] private static var mod_opportunity_25Big:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_oraclesocialnetwork_25.png')] [Bindable] private static var mod_oraclesocialnetwork_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_order_25.png')] [Bindable] private static var mod_order_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_orderitem_25.png')] [Bindable] private static var mod_orderitem_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_partnermembers_25.png')] [Bindable] private static var mod_partnermembers_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_partnertype_25.png')] [Bindable] private static var mod_partnertype_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_patient_25.png')] [Bindable] private static var mod_patient_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_period_25.png')] [Bindable] private static var mod_period_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_personalinfo_25.png')] [Bindable] private static var mod_personalinfo_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_planaccount_25.png')] [Bindable] private static var mod_planaccount_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_planopportunity_25.png')] [Bindable] private static var mod_planopportunity_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_plans_25.png')] [Bindable] private static var mod_plans_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_policy_25.png')] [Bindable] private static var mod_policy_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_policyholder_25.png')] [Bindable] private static var mod_policyholder_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_portfolio_25.png')] [Bindable] private static var mod_portfolio_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_pricelist_25.png')] [Bindable] private static var mod_pricelist_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_pricelistlineitem_25.png')] [Bindable] private static var mod_pricelistlineitem_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_product_25.png')] [Bindable] private static var mod_product_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_product_25Big.png')] [Bindable] private static var mod_product_25Big:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_productindication_25.png')] [Bindable] private static var mod_productindication_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_products_detailed_25.png')] [Bindable] private static var mod_products_detailed_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_referrals_25.png')] [Bindable] private static var mod_referrals_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_relatedaccreditation_25.png')] [Bindable] private static var mod_relatedaccreditation_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_relatedcertification_25.png')] [Bindable] private static var mod_relatedcertification_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_relatedcourse_25.png')] [Bindable] private static var mod_relatedcourse_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_relatedcourses_25.png')] [Bindable] private static var mod_relatedcourses_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_relatedexam_25.png')] [Bindable] private static var mod_relatedexam_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_relatedsolutions_25.png')] [Bindable] private static var mod_relatedsolutions_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_relationship_25.png')] [Bindable] private static var mod_relationship_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_reports_25.png')] [Bindable] private static var mod_reports_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_revenues_25.png')] [Bindable] private static var mod_revenues_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_saleshistory_25.png')] [Bindable] private static var mod_saleshistory_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_saleshours_25.png')] [Bindable] private static var mod_saleshours_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_sampledisclaimer_25.png')] [Bindable] private static var mod_sampledisclaimer_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_sampleinventory_25.png')] [Bindable] private static var mod_sampleinventory_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_samplelot_25.png')] [Bindable] private static var mod_samplelot_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_samplerequest_25.png')] [Bindable] private static var mod_samplerequest_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_samplerequestitem_25.png')] [Bindable] private static var mod_samplerequestitem_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_samplesdropped_25.png')] [Bindable] private static var mod_samplesdropped_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_sampletransaction_25.png')] [Bindable] private static var mod_sampletransaction_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_servicehistory_25.png')] [Bindable] private static var mod_servicehistory_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_servicehours_25.png')] [Bindable] private static var mod_servicehours_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_servicerequest_25.png')] [Bindable] private static var mod_servicerequest_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_servicerequest_25Big.png')] [Bindable] private static var mod_servicerequest_25Big:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_signature_25.png')] [Bindable] private static var mod_signature_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_social_25.png')] [Bindable] private static var mod_social_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_socialprofile_25.png')] [Bindable] private static var mod_socialprofile_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_solution_25.png')] [Bindable] private static var mod_solution_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_specialpricingproduct_25.png')] [Bindable] private static var mod_specialpricingproduct_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_specialpricingrequest_25.png')] [Bindable] private static var mod_specialpricingrequest_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_team_25.png')] [Bindable] private static var mod_team_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_territory_25.png')] [Bindable] private static var mod_territory_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_territory_25Big.png')] [Bindable] private static var mod_territory_25Big:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_transactionitem_25.png')] [Bindable] private static var mod_transactionitem_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_unknown_25.png')] [Bindable] private static var mod_unknown_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_user_25.png')] [Bindable] private static var mod_user_25:Class;
		[Embed(source='/assets/custom/oracleModernIcons/mod_vehicle_25.png')] [Bindable] private static var mod_vehicle_25:Class;

		
		public static function getColorIcon():Object{
			return {"/assets/red.gif":red,
				"/assets/green.gif":green,
				"/assets/yellow.gif":yellow,
				"/assets/blue.gif":blue,
				"/assets/orange.gif":orange,
				"/assets/purple.gif":purple,
				"/assets/gray.gif":gray,
				"/assets/white.gif":white,
				"/assets/black.gif":black
			};
		}
		public static function getIconByName(custom_layout_icon:String): Class {
			
			switch(custom_layout_icon){
				case "flag_blue": return blueIcon;
				case "flag_green": return greenIcon;
				case "flag_orange": return orangeIcon;
				case "flag_pink": return pinkIcon;
				case "flag_purple": return purpleIcon;
				case "flag_red": return redIcon;
				case "flag_yellow": return yellowIcon;
				case "account": return accountImg;
				case "accountBW": return accountBWImg;
				case "accountDefault": return accountDefaultImg;
				case "accountDefaultBW": return accountDefaultBWImg;
				case "asset": return assetImg;
				case "assetBW": return assetBWImg;
				case "assetDefault": return assetDefaultImg;
				case "assetDefaultBW": return assetDefaultBWImg;
				case "contact" : return contactImg;
				case "contactBW" : return contactBWImg;
				case "contactDefault": return contactDefaultImg;
				case "contactDefaultBW": return contactDefaultBWImg;
				case "opportunity" : return opportunityImg;
				case "opportunityBW" : return opportunityBWImg;
				case "opportunityDefault": return opportunityDefaultImg;
				case "opportunityDefaultBW": return opportunityDefaultBWImg;	
				case "activity": return activityImg;
				case "activityBW": return activityBWImg;	
				case "activityTaskDefault": return activityTaskDefaultImg;
				case "activityTaskDefaultBW": return activityTaskDefaultBWImg;
				case "activityAppointmentDefault": return activityAppointmentDefaultImg;
				case "activityAppointmentDefaultBW": return activityAppointmentDefaultBWImg;
				case "service": return serviceImg;
				case "serviceBW": return serviceBWImg;	
				case "serviceDefault": return serviceDefaultImg;
				case "serviceDefaultBW": return serviceDefaultBWImg;	
				case "product": return productImg;
				case "productBW": return productBWImg;
				case "productDefault": return productDefaultImg;
				case "productDefaultBW": return productDefaultBWImg;
				case "campaign": return campaignImg;
				case "campaignBW": return campaignBWImg;
				case "campaignDefault": return campaignDefaultImg;
				case "campaignDefaultBW": return campaignDefaultBWImg;
				case "custom": return customObjectImg;
				case "customBW": return customBWImg;	
				case "customDefault": return customObjectDefaultImg;
				case "customDefaultBW": return customObjectDefaultBWImg;
					
				case "custom2": return customObject2Img;
				case "custom2BW": return custom2BWImg;	
				case "custom2Default": return customObject2DefaultImg;
				case "custom2DefaultBW": return custom2DefaultBWImg;	
					
				case "custom3": return customObject3Img;
				case "custom3BW": return custom3BWImg;	
				case "custom3Default": return customObject3DefaultImg;
				case "custom3DefaultBW": return custom3DefaultBWImg;	
					
				case "custom7": return customObject7Img;
				case "custom7BW": return custom7BWImg;	
				case "custom7Default": return customObject7DefaultImg;
				case "custom7DefaultBW": return custom7DefaultBWImg;	
					
				case "custom14": return customObject14Img;	
				case "custom14BW": return custom14BWImg;	
				case "custom14Default": return customObject14DefaultImg;
				case "custom14DefaultBW": return custom14DefaultBWImg;	
					
				case "custom15": return customObject15Img;
				case "custom15BW": return custom15BWImg;		
				case "custom15Default": return customObject15DefaultImg;
				case "custom15DefaultBW": return custom15DefaultBWImg;	
					
				case "custom4": return customObject4Img;
				case "custom4BW": return custom4BWImg;		
				case "custom4Default": return customObject4DefaultImg;
				case "custom4DefaultBW": return custom4DefaultBWImg;	
					
				case "custom5": return customObject5Img;
				case "custom5BW": return custom5BWImg;	
				case "custom5Default": return customObject5DefaultImg;	
				case "custom5DefaultBW": return custom5DefaultBWImg;
				
				case "custom6": return customObject6Img;
				case "custom6BW": return custom6BWImg;	
				case "custom6Default": return customObject6DefaultImg;	
				case "custom6DefaultBW": return custom6DefaultBWImg;	
				
				case "custom8": return customObject8Img;
				case "custom8BW": return custom8BWImg;	
				case "custom8Default": return customObject8DefaultImg;	
				case "custom8DefaultBW": return custom8DefaultBWImg;	
				
				case "custom9": return customObject9Img;
				case "custom9BW": return custom9BWImg;	
				case "custom9Default": return customObject9DefaultImg;	
				case "custom9DefaultBW": return custom9DefaultBWImg;
				
				case "custom10": return customObject10Img;
				case "custom10BW": return custom10BWImg;	
				case "custom10Default": return customObject10DefaultImg;	
				case "custom10DefaultBW": return custom10DefaultBWImg;	
					
				case "custom11": return customObject11Img;
				case "custom11BW": return custom11BWImg;	
				case "custom11Default": return customObject11DefaultImg;	
				case "custom11DefaultBW": return custom11DefaultBWImg;
					
				case "custom12": return customObject12Img;
				case "custom12BW": return custom12BWImg;	
				case "custom12Default": return customObject12DefaultImg;	
				case "custom12DefaultBW": return custom12DefaultBWImg;	
					
				case "custom13": return customObject13Img;
				case "custom13BW": return custom13BWImg;	
				case "custom13Default": return customObject13DefaultImg;	
				case "custom13DefaultBW": return custom13DefaultBWImg;	
					
				case "lead": return leadImg;
				case "leadDefault": return leadDefaultImg;	
				case "activityCallDefault": return activityCallDefaultImg;
				case "territory": return territoryImg;
				case "territoryDefault": return territoryImg;
//				case "territoryDefaultBW": return assetDefaultBWImg;
				case "note": return noteImg;
				case "noteBW": return noteBWImg;
				case "noteDefault": return noteDefaultImg;	
				case "noteDefaultBW": return noteDefaultBWImg;	
				
				case "MedEd": return medEdImg;
				case "MedEdBW": return medEdBWImg;
				case "MedEdDefault": return medEdDefaultImg;	
				case "MedEdDefaultBW": return medEdDefaultBWImg;		
					
				case "objectives": return objectivesImg;
				case "objectivesBW": return objectivesBWImg;	
				case "ObjectivesDefault": return objectivesDefaultImg;	
				case "objectivesDefaultBW": return objectivesDefaultBWImg;			
					

				case 'mod_calendar_25' : return mod_calendar_25;
				case 'mod_account_25' : return mod_account_25;
				case 'mod_assets_25' : return mod_assets_25;
				case 'mod_asset_25' : return mod_assets_25;
				case 'mod_notes_25' : return mod_notes_25;
				case 'mod_note_25' : return mod_notes_25;
				case 'mod_contact_25' : return mod_contact_25;
				case 'mod_contactbesttime_25' : return mod_contactbesttime_25;
				case 'mod_objective_25' : return mod_objective_25;
				case 'mod_objectives_25' : return mod_objective_25;
					
				case 'mod_opportunity_25' : return mod_opportunity_25;
				case 'mod_product_25' : return mod_product_25;
				case 'mod_servicerequest_25' : return mod_servicerequest_25;
				case 'mod_campaign_25' : return mod_campaign_25;
				case 'mod_lead_25' : return mod_lead_25;
				case 'mod_customobject_25' : return mod_customobject_25;
				case 'mod_territory_25' : return mod_territory_25;
					
				default: return null;
			}
		}
		
		
		public static function getImagePath(imageClass:Class):String{
			if(imageClass==accountImg){
				return "/assets/account.png";
			}
			else if(imageClass==accountDefaultImg){
				return "/assets/custom/si_account16.gif";
			}
			return "";
		}
		
		public static function getCustomLayoutIconsByEntity(entity:String):ArrayCollection{
			var tmp:ArrayCollection = new ArrayCollection();
			switch (entity) {
				case "Account" :
					tmp.addItem({name: 'account', icon: accountImg});
					tmp.addItem({name: 'accountDefault', icon: accountDefaultImg});
					return tmp;
				case "Asset" :
					tmp.addItem({name: 'asset', icon: assetImg});
					tmp.addItem({name: 'assetDefault', icon: assetDefaultImg});
					return tmp;
				case "Contact" :
					tmp.addItem({name: 'contact', icon: contactImg});
					tmp.addItem({name: 'contactDefault', icon: contactDefaultImg});
					return tmp;
				case "Opportunity" :
					tmp.addItem({name: 'opportunity', icon: opportunityImg});
					tmp.addItem({name: 'opportunityDefault', icon: opportunityDefaultImg});
					return tmp;
				case "Product" : 
					tmp.addItem({name: 'product', icon: productImg});
					tmp.addItem({name: 'productDefault', icon: productDefaultImg});
					return tmp;
				case "Service Request" : 
					tmp.addItem({name: 'service', icon: serviceImg});
					tmp.addItem({name: 'serviceDefault', icon: serviceDefaultImg});
					return tmp;
				case "Activity" :
					tmp.addItem({name: 'activity', icon: activityImg});
					tmp.addItem({name: 'activityTaskDefault', icon: activityTaskDefaultImg});
					tmp.addItem({name: 'activityAppointmentDefault', icon: activityAppointmentDefaultImg});
					tmp.addItem({name: 'activityCallDefault', icon: activityCallDefaultImg});
					return tmp;
				case "Campaign" : 
					tmp.addItem({name: 'campaign', icon: campaignImg});
					tmp.addItem({name: 'campaignDefault', icon: campaignDefaultImg});
					return tmp;
				case "Custom Object 1" :
					tmp.addItem({name: 'custom', icon: customObjectImg});
					tmp.addItem({name: 'customDefault', icon: customObjectDefaultImg});
					return tmp;
				case "Lead" : 
					tmp.addItem({name: 'lead', icon: leadImg});
					tmp.addItem({name: 'leadDefault', icon: leadDefaultImg});
					return tmp;
				case "Custom Object 2" :
					tmp.addItem({name: 'custom2', icon: customObject2Img});
					tmp.addItem({name: 'custom2Default', icon: customObject2DefaultImg});
					return tmp;
				case "Custom Object 3" :
					tmp.addItem({name: 'custom3', icon: customObject3Img});
					tmp.addItem({name: 'custom3Default', icon: customObject3DefaultImg});
					return tmp;
				case "CustomObject7" :
					tmp.addItem({name: 'custom7', icon: customObject7Img});
					tmp.addItem({name: 'custom7Default', icon: customObject7DefaultImg});
					return tmp;
				case "CustomObject14" :
					tmp.addItem({name: 'custom14', icon: customObject14Img});
					tmp.addItem({name: 'custom14Default', icon: customObject14DefaultImg});
					return tmp;
				case "CustomObject4" :
					tmp.addItem({name: 'custom4', icon: customObject4Img});
					tmp.addItem({name: 'custom4Default', icon: customObject4DefaultImg});
					return tmp;	
				case "CustomObject5" :
					tmp.addItem({name: 'custom5', icon: customObject5Img});
					tmp.addItem({name: 'custom5Default', icon: customObject5DefaultImg});
					return tmp;		
				case "CustomObject6" :
					tmp.addItem({name: 'custom6', icon: customObject8Img});
					tmp.addItem({name: 'custom6Default', icon: customObject6DefaultImg});
					return tmp;	
				case "CustomObject8" :
					tmp.addItem({name: 'custom8', icon: customObject8Img});
					tmp.addItem({name: 'custom8Default', icon: customObject8DefaultImg});
					return tmp;
				case "CustomObject9" :
					tmp.addItem({name: 'custom9', icon: customObject9Img});
					tmp.addItem({name: 'custom9Default', icon: customObject9DefaultImg});
					return tmp;		
				case "CustomObject10" :
					tmp.addItem({name: 'custom10', icon: customObject10Img});
					tmp.addItem({name: 'custom10Default', icon: customObject10DefaultImg});
					return tmp;			
				case "Picklist" :
					tmp.addItem({name: 'picklist', icon: picklistImg});
					return tmp;
				case "Territory" :
					tmp.addItem({name: 'territory', icon: territoryImg});
					return tmp;
				case "Note" :
					tmp.addItem({name: 'Note', icon: medEdImg});
					tmp.addItem({name: 'NoteDefault', icon: noteDefaultImg});
					return tmp;	
				case "MedEd Event" :
					tmp.addItem({name: 'MedEd', icon: noteImg});
					tmp.addItem({name: 'MedEdDefault', icon: medEdDefaultImg});
					return tmp;			
				case "BusinessPlan" :
					tmp.addItem({name: 'businessPlan', icon: businessPlanImg});
					return tmp;	
				case "Objetives" :
					tmp.addItem({name: 'objectives', icon: objectivesImg});
					return tmp;	
				default: return null;
			}
		}		
		
		public static function getFlagIcon():ArrayCollection{
			var array:ArrayCollection = new ArrayCollection();
			var object:Object = new Object();
			object.data = "flag_blue";
			object.icon = blueIcon;
			object.label = "";
			array.addItem(object);
			
			object = new Object();
			object.data = "flag_green";
			object.icon = greenIcon;
			object.label = "";
			array.addItem(object);
			
			object = new Object();
			object.data = "flag_orange";
			object.icon = orangeIcon;
			object.label = "";
			array.addItem(object);
			
			object = new Object();
			object.data = "flag_pink";
			object.icon = pinkIcon;
			object.label = "";
			array.addItem(object);
			
			object = new Object();
			object.data = "flag_purple";
			object.icon = purpleIcon;
			object.label = "";
			array.addItem(object);
			
			object = new Object();
			object.data = "flag_red";
			object.icon = redIcon;
			object.label = "";
			array.addItem(object);
			
			object = new Object();
			object.data = "flag_yellow";
			object.icon = yellowIcon;
			object.label = "";
			array.addItem(object);
			return array;
		}
		
		public static function getImage_custom(fileName:String):Class{
			
			if(!oodIcons_cache){
				loadOODIcons_Cache();
			}
			if(fileName == null){
				return null;
			}
			fileName = fileName.replace(".gif","");
			fileName = fileName.replace(".png","");
			fileName = "icon_" + fileName;
			//trace("FileName : " + fileName);
			// return oodIcons_cache.get(fileName, customObjectImg) as Class;
			return oodIcons_cache.get(fileName) as Class;
			
			// return '/assets/custom/oracleicons/' + fileName;
		}
		
		/**
		 * 
		 * @param entity
		 * @param subtype
		 * @param isPrimary
		 * @return 
		 * 
		 */
		public static function getImage(entity:String, subtype:int = 0, isPrimary:Boolean = false):Class{
//			switch (entity) {
//				case "Account" : return accountImg;
//				case "Contact" : return contactImg;
//				case "Opportunity" : return opportunityImg;
//				case "Product" : return productImg;
//				case "Service Request" : return serviceImg;
//				case "Activity" : return activityImg;
//				case "Campaign" : return campaignImg;
//				case "Custom Object 1" : return customObjectImg;
//				case "Picklist" : return picklistImg;
//				case "Lead" : return leadImg;
//				default: return null;
//			}
			//MOny--hack title....
			
			if(CustomRecordTypeServiceDAO.isCustomObject(entity) || Database.preferencesDao.isModernIcon()){
				var oodIcon:Class = Database.customRecordTypeServiceDao.readIcon(entity);
				if(oodIcon){
					return oodIcon;
				}
			}
			
			if(entity == Database.accountCompetitorDao.entity){
				entity = "Account";	
			}
			if(entity==Database.accountPartnerDao.entity){
				entity = "Account";
			}
			
			if(entity==Database.opportunityPartnerDao.entity){
				entity = "Opportunity";
			}
			
			if(entity==Database.opportunityProductRevenueDao.entity){
				entity = "Opportunity";
			}
			
			if(entity == Database.relatedContactDao.entity){
				entity = Database.contactDao.entity;
			}
			
			
			
			if(entity.indexOf("Note")!=-1 && entity.indexOf(".")!=-1){
				entity = entity.substring( entity.indexOf(".")+1);
			}
			
			
			
			if( entity == MainWindow.VISIT_CUSTOMER ) return contactImg;
			if( entity == MainWindow.DASHBOARD || entity == MainWindow.REVENUE_REPORT) return chartBar;
			
			if( entity == MainWindow.CHAT ) return chat;
			
			if( entity == MainWindow.DAILY_AGENDA ) return dailyAgenda;
			
			if( entity == "GCalendar" ) return gCalendarIcon;
			
			if( entity == "Picklist" ) return picklistImg;
			var customLayout:Object = Database.customLayoutDao.readSubtype(entity,subtype);
			
			if( entity == "BusinessPlan" ) return businessPlanImg;
			
			var customLayout:Object = Database.customLayoutDao.readSubtype(entity,subtype);
			if( isPrimary ){
				if ( StringUtils.endsWith(customLayout.custom_layout_icon, "Default") ){
					return pContactDefaultIcon;
				}else {
					return pContactIcon;
				}
			}
			//mony--fixed npe
			if(customLayout==null){
				return null;
			}
			return getIconByName(customLayout.custom_layout_icon); 
			
		}

		public static function getImageBW(entity:String, subtype:int = 0):Class{
			var customLayout:Object = Database.customLayoutDao.readSubtype(entity,subtype);
			return getIconBWByEntity(customLayout.custom_layout_icon + "BW"); 
		}	
		
		public static function getIconBWByEntity(entity:String): Class {
			switch(entity){
				
				case "accountBW": return accountBWImg;
				case "accountDefaultBW": return accountDefaultBWImg;
				case "assetBW": return assetBWImg;
				case "assetDefaultBW": return assetDefaultBWImg;
				case "contactBW" : return contactBWImg;
				case "contactDefaultBW": return contactDefaultBWImg;
				case "opportunityBW" : return opportunityBWImg;
				case "opportunityDefaultBW": return opportunityDefaultBWImg;
				case "activityBW": return activityBWImg;
				case "activityTaskDefaultBW": return activityTaskDefaultBWImg;
				case "activityAppointmentDefaultBW": return activityAppointmentDefaultBWImg;
				case "serviceBW": return serviceBWImg;
				case "serviceDefaultBW": return serviceDefaultBWImg;
				case "campaignBW": return campaignBWImg;
				case "campaignDefaultBW": return campaignDefaultBWImg;
					
				case "customBW": return customBWImg;
				case "customDefaultBW": return customDefaultBWImg;
				
				case "custom2BW": return custom2BWImg;
				case "custom2DefaultBW": return custom2DefaultBWImg;
					
				case "custom3BW": return custom3BWImg;
				case "custom3DefaultBW": return custom3DefaultBWImg;
					
				case "custom7BW": return custom7BWImg;
				case "custom7DefaultBW": return custom7DefaultBWImg;
					
				case "custom14BW": return custom14BWImg;
				case "custom14DefaultBW": return custom14DefaultBWImg;
				
				case "custom4BW": return custom4BWImg;
				case "custom4DefaultBW": return custom4DefaultBWImg;
				
				case "custom5BW": return custom5BWImg;
				case "custom5DefaultBW": return custom5DefaultBWImg;	
				
				case "custom6BW": return custom6BWImg;
				case "custom6DefaultBW": return custom6DefaultBWImg;
				
				case "custom6BW": return custom6BWImg;
				case "custom6DefaultBW": return custom6DefaultBWImg;
				
				case "custom8BW": return custom8BWImg;
				case "custom8DefaultBW": return custom8DefaultBWImg;
				
				case "custom9BW": return custom9BWImg;
				case "custom9DefaultBW": return custom9DefaultBWImg;	
				
				case "custom10BW": return custom10BWImg;
				case "custom10DefaultBW": return custom10DefaultBWImg;		
					
				case "leadBW": return leadBWImg;
				case "leadDefaultBW": return leadDefaultBWImg;
					
				case "productBW": return productBWImg;
				case "productDefaultBW": return productDefaultBWImg;
					
				case "flag_blueBW":
				case "flag_greenBW":
				case "flag_orangeBW":
				case "flag_pinkBW":
				case "flag_purpleBW":
				case "flag_redBW":
				case "flag_yellowBW": return flagBWImg;
				
				case "noteBW": return noteBWImg;
				case "noteDefaultBW": return noteDefaultBWImg;
				
				case "medEdBW": return medEdBWImg;
				case "medEdDefaultBW":  medEdDefaultBWImg;	
					
				case "Objectives":  objectivesBWImg;		
				default: return null;
			}
		}		
		
		public static function getBigImage(entity:String):Class{
//			switch (entity) {
//				case "Account" : return accountBigImg;
//				case "Contact" : return contactBigImg;
//				case "Opportunity" : return opportunityBigImg;
//				case "Product" : return productBigImg;
//				case "Service Request" : return serviceBigImg;
//				case "Activity" : return activityBigImg;
//				case "Campaign" : return campaignBigImg;
//				case "Custom Object 1" : return customBigImg;
//				case "Lead" : return leadBigImg;
//				default: return null;
//			}
			switch(entity){
				case MainWindow.DASHBOARD : return chartBar;
				case MainWindow.REVENUE_REPORT : return chartBar;
				case MainWindow.CHAT : return chat;
				case MainWindow.DAILY_AGENDA : return dailyAgenda;
					
			}
			var customLayout:Object = Database.customLayoutDao.readSubtype(entity,0);
			switch(customLayout.custom_layout_icon){
				
				case "account": return accountBigImg;
				case "accountDefault": return accountDefaultBigImg;
				case "asset": return assetBigImg;
				case "assetDefault": return assetDefaultBigImg;
				case "contact" : return contactBigImg;
				case "contactDefault": return contactDefaultBigImg;
				case "opportunity" : return opportunityBigImg;
				case "opportunityDefault": return opportunityDefaultBigImg;
				case "activity": return activityBigImg;
				case "activityTaskDefault": return activityTaskDefaultBigImg;
				case "activityAppointmentDefault": return activityAppointmentDefaultBigImg;
				case "service": return serviceBigImg;
				case "serviceDefault": return serviceDefaultBigImg;
				case "product": return productBigImg;
				case "productDefault": return productDefaultBigImg;
				case "campaign": return campaignBigImg;
				case "campaignDefault": return campaignDefaultBigImg;
				case "custom": return customBigImg;
				case "customDefault": return customObjectDefaultBigImg;
				case "custom2": return custom2BigImg;
				case "custom2Default": return customObject2DefaultBigImg;
				case "custom3": return custom3BigImg;
				case "custom3Default": return customObject3DefaultBigImg;
				case "custom7": return custom7BigImg;
				case "custom7Default": return customObject7DefaultBigImg;
				case "custom14": return custom14BigImg;
				case "custom14Default": return customObject14DefaultBigImg;
				case "custom4": return custom4BigImg;
				case "custom4Default": return customObject4DefaultBigImg;
				case "custom5": return custom5BigImg;
				case "custom5Default": return customObject5DefaultBigImg;	
				case "custom6": return custom6BigImg;
				case "custom6Default": return customObject6DefaultBigImg;	
				case "custom8": return custom8BigImg;
				case "custom8Default": return customObject8DefaultBigImg;	
				case "custom9": return custom9BigImg;
				case "custom9Default": return customObject9DefaultBigImg;	
				case "custom10": return custom10BigImg;
				case "custom10Default": return customObject10DefaultBigImg;		
				case "lead": return leadBigImg;
				case "leadDefault": return leadDefaultBigImg;
				case "flag_blue": return blueIcon;
				case "flag_green": return greenIcon;
				case "flag_orange": return orangeIcon;
				case "flag_pink": return pinkIcon;
				case "flag_purple": return purpleIcon;
				case "flag_red": return redIcon;
				case "flag_yellow": return yellowIcon;
				case "note": return noteBigImg;
				case "noteDefault": return noteDefaultBigImg;
				case "menEd": return medEdBigImg;
				case "medEdDefault": return medEdDefaultBigImg;	
					
				case 'mod_calendar_25' : return mod_calendar_25Big;
				case 'mod_account_25' : return mod_account_25Big;
				case 'mod_assets_25' : return mod_assets_25Big;
				case 'mod_asset_25' : return mod_assets_25Big;
				case 'mod_contactbesttime_25' : return mod_contactbesttime_25Big;
				case 'mod_contact_25' : return mod_contact_25Big;
				case 'mod_opportunity_25' : return mod_opportunity_25Big;
				case 'mod_product_25' : return mod_product_25Big;
				case 'mod_servicerequest_25' : return mod_servicerequest_25Big;
				case 'mod_campaign_25' : return mod_campaign_25Big;
				case 'mod_lead_25' : return mod_lead_25Big;
				case 'mod_customobject_25' : return mod_customobject_25Big;
				case 'mod_territory_25' : return mod_territory_25Big;
					
				default: return null;
			}
			
		}
		
		
		
		/**
		 * 	1) activity != Appointment 									-----------> TASK
		 *	2) activity = Appointment and CallType != 'Account Call' 	-----------> APPOINTMENT
		 *	3) activity = Appointment and CallType = 'Account Call' 	-----------> CALL
		 */
		
		public static function getActivitySubType(activity:Object):int{
			if(activity["Activity"] != "Appointment") {
				return 0; // Task Image
			}else if(activity["Activity"] == "Appointment" && activity["CallType"] != "Account Call") {
				return 1; // Appointment Image
			}else if(activity["Activity"] == "Appointment" && activity["CallType"] == "Account Call") {
				return 2; // Call Image
			}
			return 0;
		}
		
		
		public static function getImageDailyAgenda(item:Object):Class {
			return getImage("Activity", getActivitySubType(item));
		}
		
		public static function getByteArray(encoded:String):ByteArray {
			var base64Dec:Base64Decoder = new Base64Decoder();
			base64Dec.decode(encoded);
			return base64Dec.toByteArray();
		}
		
//		public static function getImageByType(item:Object):Class {
//			var image:Class;
//			if (item == null) return null;
//			switch (item.gadget_type) {
//				case 'A': return accountImg; //Account
//				case 'C': return contactImg; //Contact
//				case 'O': return opportunityImg; //Opportunity
//				case 'Y': return activityImg; //Activity
//				case 'P': return productImg; //Product
//				case 'S': return serviceImg; //ServiceRequest
//				case 'G': return campaignImg; //Campaign
//				case 'B': return customObjectImg; //CustomObject
//				default: return null;
//			}
//			return image;
//		}
		
		public static var oodIcons_cache:CacheUtils = null;
		
		public static function loadOODIcons_Cache():void {
			if(oodIcons_cache){
				return;
			}
			oodIcons_cache = new CacheUtils("OODIcons");	
			oodIcons_cache.put("icon_1006", icon_1006);
			oodIcons_cache.put("icon_1033", icon_1033);
			oodIcons_cache.put("icon_1048", icon_1048);
			oodIcons_cache.put("icon_1056", icon_1056);
			oodIcons_cache.put("icon_16_account", icon_16_account);
			oodIcons_cache.put("icon_16_accountPDQPinned", icon_16_accountPDQPinned);
			oodIcons_cache.put("icon_16_accounts", icon_16_accounts);
			oodIcons_cache.put("icon_16_account_contact", icon_16_account_contact);
			oodIcons_cache.put("icon_16_addresses", icon_16_addresses);
			oodIcons_cache.put("icon_16_alerts_grid", icon_16_alerts_grid);
			oodIcons_cache.put("icon_16_analytics_grid", icon_16_analytics_grid);
			oodIcons_cache.put("icon_16_aroundme_grid", icon_16_aroundme_grid);
			oodIcons_cache.put("icon_16_bestCallTime", icon_16_bestCallTime);
			oodIcons_cache.put("icon_16_calendar_grid", icon_16_calendar_grid);
			oodIcons_cache.put("icon_16_callHistory", icon_16_callHistory);
			oodIcons_cache.put("icon_16_callProductDetails", icon_16_callProductDetails);
			oodIcons_cache.put("icon_16_contacts", icon_16_contacts);
			oodIcons_cache.put("icon_16_contacts_grid", icon_16_contacts_grid);
			oodIcons_cache.put("icon_16_generic_grid", icon_16_generic_grid);
			oodIcons_cache.put("icon_16_gift", icon_16_gift);
			oodIcons_cache.put("icon_16_launchDetailer", icon_16_launchDetailer);
			oodIcons_cache.put("icon_16_launchPresentation", icon_16_launchPresentation);
			oodIcons_cache.put("icon_16_leads_grid", icon_16_leads_grid);
			oodIcons_cache.put("icon_16_licenses", icon_16_licenses);
			oodIcons_cache.put("icon_16_opportunities_grid", icon_16_opportunities_grid);
			oodIcons_cache.put("icon_16_presentationDetails", icon_16_presentationDetails);
			oodIcons_cache.put("icon_16_relationships", icon_16_relationships);
			oodIcons_cache.put("icon_16_sales_accounts_grid", icon_16_sales_accounts_grid);
			oodIcons_cache.put("icon_16_sample", icon_16_sample);
			oodIcons_cache.put("icon_16_samples", icon_16_samples);
			oodIcons_cache.put("icon_16_tasks_grid", icon_16_tasks_grid);
			oodIcons_cache.put("icon_1801", icon_1801);
			oodIcons_cache.put("icon_1824", icon_1824);
			oodIcons_cache.put("icon_1826", icon_1826);
			oodIcons_cache.put("icon_application_form", icon_application_form);
			oodIcons_cache.put("icon_application_view_tile", icon_application_view_tile);
			oodIcons_cache.put("icon_arrow_divide", icon_arrow_divide);
			oodIcons_cache.put("icon_asterisk_orange", icon_asterisk_orange);
			oodIcons_cache.put("icon_attach", icon_attach);
			oodIcons_cache.put("icon_award_star_gold_1", icon_award_star_gold_1);
			oodIcons_cache.put("icon_bell", icon_bell);
			oodIcons_cache.put("icon_box", icon_box);
			oodIcons_cache.put("icon_brick", icon_brick);
			oodIcons_cache.put("icon_bug", icon_bug);
			oodIcons_cache.put("icon_building", icon_building);
			oodIcons_cache.put("icon_cake", icon_cake);
			oodIcons_cache.put("icon_camera", icon_camera);
			oodIcons_cache.put("icon_campaign_status", icon_campaign_status);
			oodIcons_cache.put("icon_car", icon_car);
			oodIcons_cache.put("icon_cart", icon_cart);
			oodIcons_cache.put("icon_catalog_status", icon_catalog_status);
			oodIcons_cache.put("icon_certificaterequired", icon_certificaterequired);
			oodIcons_cache.put("icon_chart_bar", icon_chart_bar);
			oodIcons_cache.put("icon_chart_organisation", icon_chart_organisation);
			oodIcons_cache.put("icon_chart_pie", icon_chart_pie);
			oodIcons_cache.put("icon_clock", icon_clock);
			oodIcons_cache.put("icon_cog", icon_cog);
			oodIcons_cache.put("icon_coins", icon_coins);
			oodIcons_cache.put("icon_commentind_active", icon_commentind_active);
			oodIcons_cache.put("icon_controller", icon_controller);
			oodIcons_cache.put("icon_cup", icon_cup);
			oodIcons_cache.put("icon_derived_bidi_status", icon_derived_bidi_status);
			oodIcons_cache.put("icon_disconnect", icon_disconnect);
			oodIcons_cache.put("icon_drive_network", icon_drive_network);
			oodIcons_cache.put("icon_email", icon_email);
			oodIcons_cache.put("icon_eye", icon_eye);
			oodIcons_cache.put("icon_feed_icon", icon_feed_icon);
			oodIcons_cache.put("icon_female", icon_female);
			oodIcons_cache.put("icon_film", icon_film);
			oodIcons_cache.put("icon_flag_green", icon_flag_green);
			oodIcons_cache.put("icon_heart", icon_heart);
			oodIcons_cache.put("icon_house", icon_house);
			oodIcons_cache.put("icon_HR_IMAGE5_184", icon_HR_IMAGE5_184);
			oodIcons_cache.put("icon_HR_IMAGE5_221", icon_HR_IMAGE5_221);
			oodIcons_cache.put("icon_HR_IMAGE5_249", icon_HR_IMAGE5_249);
			oodIcons_cache.put("icon_HR_IMAGE5_593", icon_HR_IMAGE5_593);
			oodIcons_cache.put("icon_HR_IMAGE5_678", icon_HR_IMAGE5_678);
			oodIcons_cache.put("icon_HR_IMAGE5_85", icon_HR_IMAGE5_85);
			oodIcons_cache.put("icon_icon_custtab", icon_icon_custtab);
			oodIcons_cache.put("icon_instore_status", icon_instore_status);
			oodIcons_cache.put("icon_ipod", icon_ipod);
			oodIcons_cache.put("icon_key", icon_key);
			oodIcons_cache.put("icon_lightbulb", icon_lightbulb);
			oodIcons_cache.put("icon_lightning", icon_lightning);
			oodIcons_cache.put("icon_locked_status", icon_locked_status);
			oodIcons_cache.put("icon_male", icon_male);
			oodIcons_cache.put("icon_map", icon_map);
			oodIcons_cache.put("icon_money", icon_money);
			oodIcons_cache.put("icon_money_dollar", icon_money_dollar);
			oodIcons_cache.put("icon_money_euro", icon_money_euro);
			oodIcons_cache.put("icon_mouse", icon_mouse);
			oodIcons_cache.put("icon_newupdateditem_status", icon_newupdateditem_status);
			oodIcons_cache.put("icon_onvacation_status", icon_onvacation_status);
			oodIcons_cache.put("icon_orders_icon", icon_orders_icon);
			oodIcons_cache.put("icon_package_green", icon_package_green);
			oodIcons_cache.put("icon_paintcan", icon_paintcan);
			oodIcons_cache.put("icon_palette", icon_palette);
			oodIcons_cache.put("icon_phone", icon_phone);
			oodIcons_cache.put("icon_photo", icon_photo);
			oodIcons_cache.put("icon_plugin", icon_plugin);
			oodIcons_cache.put("icon_primary_status", icon_primary_status);
			oodIcons_cache.put("icon_printer", icon_printer);
			oodIcons_cache.put("icon_quotes_icon", icon_quotes_icon);
			oodIcons_cache.put("icon_rainbow", icon_rainbow);
			oodIcons_cache.put("icon_register_status", icon_register_status);
			oodIcons_cache.put("icon_rosette", icon_rosette);
			oodIcons_cache.put("icon_rte_image_enabled", icon_rte_image_enabled);
			oodIcons_cache.put("icon_rte_paste_enabled", icon_rte_paste_enabled);
			oodIcons_cache.put("icon_ruby", icon_ruby);
			oodIcons_cache.put("icon_shield", icon_shield);
			oodIcons_cache.put("icon_sound", icon_sound);
			oodIcons_cache.put("icon_sport_football", icon_sport_football);
			oodIcons_cache.put("icon_sport_soccer", icon_sport_soccer);
			oodIcons_cache.put("icon_telephone", icon_telephone);
			oodIcons_cache.put("icon_television", icon_television);
			oodIcons_cache.put("icon_timeexpires_status", icon_timeexpires_status);
			oodIcons_cache.put("icon_transmit", icon_transmit);
			oodIcons_cache.put("icon_tree_alert", icon_tree_alert);
			oodIcons_cache.put("icon_tree_collateral", icon_tree_collateral);
			oodIcons_cache.put("icon_tree_component", icon_tree_component);
			oodIcons_cache.put("icon_tree_configextension", icon_tree_configextension);
			oodIcons_cache.put("icon_tree_contentobject", icon_tree_contentobject);
			oodIcons_cache.put("icon_tree_database", icon_tree_database);
			oodIcons_cache.put("icon_tree_forum", icon_tree_forum);
			oodIcons_cache.put("icon_tree_grades", icon_tree_grades);
			oodIcons_cache.put("icon_tree_graph", icon_tree_graph);
			oodIcons_cache.put("icon_tree_library", icon_tree_library);
			oodIcons_cache.put("icon_tree_messages", icon_tree_messages);
			oodIcons_cache.put("icon_tree_property", icon_tree_property);
			oodIcons_cache.put("icon_tree_server", icon_tree_server);
			oodIcons_cache.put("icon_tree_servicerequest", icon_tree_servicerequest);
			oodIcons_cache.put("icon_tree_sharedobjects", icon_tree_sharedobjects);
			oodIcons_cache.put("icon_tree_site", icon_tree_site);
			oodIcons_cache.put("icon_tree_testobject", icon_tree_testobject);
			oodIcons_cache.put("icon_tree_workflow", icon_tree_workflow);
			oodIcons_cache.put("icon_tux", icon_tux);
			oodIcons_cache.put("icon_user_gray", icon_user_gray);
			oodIcons_cache.put("icon_user_orange", icon_user_orange);
			oodIcons_cache.put("icon_wand", icon_wand);
			oodIcons_cache.put("icon_weather_sun", icon_weather_sun);
			oodIcons_cache.put("icon_webpage_status", icon_webpage_status);
			oodIcons_cache.put("icon_world", icon_world);
			oodIcons_cache.put("icon_zoom", icon_zoom);

			oodIcons_cache.put("icon_mod_account_25",mod_account_25);
			oodIcons_cache.put("icon_mod_account_25_001",mod_account_25_001);
			oodIcons_cache.put("icon_mod_accountpartners_25",mod_accountpartners_25);
			oodIcons_cache.put("icon_mod_accreditation_25",mod_accreditation_25);
			oodIcons_cache.put("icon_mod_accreditationrequest_25",mod_accreditationrequest_25);
			oodIcons_cache.put("icon_mod_address_25",mod_address_25);
			oodIcons_cache.put("icon_mod_allocation_25",mod_allocation_25);
			oodIcons_cache.put("icon_mod_application_25",mod_application_25);
			oodIcons_cache.put("icon_mod_assets_25",mod_assets_25);
			oodIcons_cache.put("icon_mod_asset_25",mod_assets_25);
			oodIcons_cache.put("icon_mod_attachment_25",mod_attachment_25);
			oodIcons_cache.put("icon_mod_availableproductsfordetailing_25",mod_availableproductsfordetailing_25);
			oodIcons_cache.put("icon_mod_blockedproduct_25",mod_blockedproduct_25);
			oodIcons_cache.put("icon_mod_books_25",mod_books_25);
			oodIcons_cache.put("icon_mod_brokerprofile_25",mod_brokerprofile_25);
			oodIcons_cache.put("icon_mod_businessplan_25",mod_businessplan_25);
			oodIcons_cache.put("icon_mod_calendar_25",mod_calendar_25);
			oodIcons_cache.put("icon_mod_callactivityhistory_25",mod_callactivityhistory_25);
			oodIcons_cache.put("icon_mod_calls_25",mod_calls_25);
			oodIcons_cache.put("icon_mod_campaign_25",mod_campaign_25);
			oodIcons_cache.put("icon_mod_category_25",mod_category_25);
			oodIcons_cache.put("icon_mod_certification_25",mod_certification_25);
			oodIcons_cache.put("icon_mod_certificationrequest_25",mod_certificationrequest_25);
			oodIcons_cache.put("icon_mod_claim_25",mod_claim_25);
			oodIcons_cache.put("icon_mod_communications_25",mod_communications_25);
			oodIcons_cache.put("icon_mod_competitors_25",mod_competitors_25);
			oodIcons_cache.put("icon_mod_contact_25",mod_contact_25);
			oodIcons_cache.put("icon_mod_contactbesttime_25",mod_contactbesttime_25);
			oodIcons_cache.put("icon_mod_contactstatelicense_25",mod_contactstatelicense_25);
			oodIcons_cache.put("icon_mod_course_25",mod_course_25);
			oodIcons_cache.put("icon_mod_courseenrollment_25",mod_courseenrollment_25);
			oodIcons_cache.put("icon_mod_coverage_25",mod_coverage_25);
			oodIcons_cache.put("icon_mod_customobject_25",mod_customobject_25);
			oodIcons_cache.put("icon_mod_customwebtab_25",mod_customwebtab_25);
			oodIcons_cache.put("icon_mod_damage_25",mod_damage_25);
			oodIcons_cache.put("icon_mod_dashboard_25",mod_dashboard_25);
			oodIcons_cache.put("icon_mod_dealer_25",mod_dealer_25);
			oodIcons_cache.put("icon_mod_dealregistration_25",mod_dealregistration_25);
			oodIcons_cache.put("icon_mod_dealregistrationproductrevenue_25",mod_dealregistrationproductrevenue_25);
			oodIcons_cache.put("icon_mod_directory_25",mod_directory_25);
			oodIcons_cache.put("icon_mod_division_25",mod_division_25);
			oodIcons_cache.put("icon_mod_event_25",mod_event_25);
			oodIcons_cache.put("icon_mod_exam_25",mod_exam_25);
			oodIcons_cache.put("icon_mod_exam_registration_25",mod_exam_registration_25);
			oodIcons_cache.put("icon_mod_financialaccount_25",mod_financialaccount_25);
			oodIcons_cache.put("icon_mod_financialaccountholder_25",mod_financialaccountholder_25);
			oodIcons_cache.put("icon_mod_financialaccountholding_25",mod_financialaccountholding_25);
			oodIcons_cache.put("icon_mod_financialplan_25",mod_financialplan_25);
			oodIcons_cache.put("icon_mod_financialproduct_25",mod_financialproduct_25);
			oodIcons_cache.put("icon_mod_financialtransaction_25",mod_financialtransaction_25);
			oodIcons_cache.put("icon_mod_forecast_25",mod_forecast_25);
			oodIcons_cache.put("icon_mod_fund_25",mod_fund_25);
			oodIcons_cache.put("icon_mod_fundcredit_25",mod_fundcredit_25);
			oodIcons_cache.put("icon_mod_funddebit_25",mod_funddebit_25);
			oodIcons_cache.put("icon_mod_fundrequest_25",mod_fundrequest_25);
			oodIcons_cache.put("icon_mod_group_25",mod_group_25);
			oodIcons_cache.put("icon_mod_hash_25",mod_hash_25);
			oodIcons_cache.put("icon_mod_hcpcontactallocation_25",mod_hcpcontactallocation_25);
			oodIcons_cache.put("icon_mod_home_25",mod_home_25);
			oodIcons_cache.put("icon_mod_household_25",mod_household_25);
			oodIcons_cache.put("icon_mod_insuranceproperty_25",mod_insuranceproperty_25);
			oodIcons_cache.put("icon_mod_interests_25",mod_interests_25);
			oodIcons_cache.put("icon_mod_inventoryauditreport_25",mod_inventoryauditreport_25);
			oodIcons_cache.put("icon_mod_inventoryperiod_25",mod_inventoryperiod_25);
			oodIcons_cache.put("icon_mod_involvedparty_25",mod_involvedparty_25);
			oodIcons_cache.put("icon_mod_lead_25",mod_lead_25);
			oodIcons_cache.put("icon_mod_makes_25",mod_makes_25);
			oodIcons_cache.put("icon_mod_map_25",mod_map_25);
			oodIcons_cache.put("icon_mod_mdfrequest_25",mod_mdfrequest_25);
			oodIcons_cache.put("icon_mod_messageresponse_25",mod_messageresponse_25);
			oodIcons_cache.put("icon_mod_messagingplan_25",mod_messagingplan_25);
			oodIcons_cache.put("icon_mod_messagingplanitem_25",mod_messagingplanitem_25);
			oodIcons_cache.put("icon_mod_messagingplanitemrelations_25",mod_messagingplanitemrelations_25);
			oodIcons_cache.put("icon_mod_modificationtracking_25",mod_modificationtracking_25);
			oodIcons_cache.put("icon_mod_notes_25",mod_notes_25);
			oodIcons_cache.put("icon_mod_note_25",mod_notes_25);
			oodIcons_cache.put("icon_mod_objective_25",mod_objective_25);
			oodIcons_cache.put("icon_mod_objectives_25",mod_objective_25);
			oodIcons_cache.put("icon_mod_opportunity_25",mod_opportunity_25);
			oodIcons_cache.put("icon_mod_oraclesocialnetwork_25",mod_oraclesocialnetwork_25);
			oodIcons_cache.put("icon_mod_order_25",mod_order_25);
			oodIcons_cache.put("icon_mod_orderitem_25",mod_orderitem_25);
			oodIcons_cache.put("icon_mod_partnermembers_25",mod_partnermembers_25);
			oodIcons_cache.put("icon_mod_partnertype_25",mod_partnertype_25);
			oodIcons_cache.put("icon_mod_patient_25",mod_patient_25);
			oodIcons_cache.put("icon_mod_period_25",mod_period_25);
			oodIcons_cache.put("icon_mod_personalinfo_25",mod_personalinfo_25);
			oodIcons_cache.put("icon_mod_planaccount_25",mod_planaccount_25);
			oodIcons_cache.put("icon_mod_planopportunity_25",mod_planopportunity_25);
			oodIcons_cache.put("icon_mod_plans_25",mod_plans_25);
			oodIcons_cache.put("icon_mod_policy_25",mod_policy_25);
			oodIcons_cache.put("icon_mod_policyholder_25",mod_policyholder_25);
			oodIcons_cache.put("icon_mod_portfolio_25",mod_portfolio_25);
			oodIcons_cache.put("icon_mod_pricelist_25",mod_pricelist_25);
			oodIcons_cache.put("icon_mod_pricelistlineitem_25",mod_pricelistlineitem_25);
			oodIcons_cache.put("icon_mod_product_25",mod_product_25);
			oodIcons_cache.put("icon_mod_productindication_25",mod_productindication_25);
			oodIcons_cache.put("icon_mod_products_detailed_25",mod_products_detailed_25);
			oodIcons_cache.put("icon_mod_referrals_25",mod_referrals_25);
			oodIcons_cache.put("icon_mod_relatedaccreditation_25",mod_relatedaccreditation_25);
			oodIcons_cache.put("icon_mod_relatedcertification_25",mod_relatedcertification_25);
			oodIcons_cache.put("icon_mod_relatedcourse_25",mod_relatedcourse_25);
			oodIcons_cache.put("icon_mod_relatedcourses_25",mod_relatedcourses_25);
			oodIcons_cache.put("icon_mod_relatedexam_25",mod_relatedexam_25);
			oodIcons_cache.put("icon_mod_relatedsolutions_25",mod_relatedsolutions_25);
			oodIcons_cache.put("icon_mod_relationship_25",mod_relationship_25);
			oodIcons_cache.put("icon_mod_reports_25",mod_reports_25);
			oodIcons_cache.put("icon_mod_revenues_25",mod_revenues_25);
			oodIcons_cache.put("icon_mod_saleshistory_25",mod_saleshistory_25);
			oodIcons_cache.put("icon_mod_saleshours_25",mod_saleshours_25);
			oodIcons_cache.put("icon_mod_sampledisclaimer_25",mod_sampledisclaimer_25);
			oodIcons_cache.put("icon_mod_sampleinventory_25",mod_sampleinventory_25);
			oodIcons_cache.put("icon_mod_samplelot_25",mod_samplelot_25);
			oodIcons_cache.put("icon_mod_samplerequest_25",mod_samplerequest_25);
			oodIcons_cache.put("icon_mod_samplerequestitem_25",mod_samplerequestitem_25);
			oodIcons_cache.put("icon_mod_samplesdropped_25",mod_samplesdropped_25);
			oodIcons_cache.put("icon_mod_sampletransaction_25",mod_sampletransaction_25);
			oodIcons_cache.put("icon_mod_servicehistory_25",mod_servicehistory_25);
			oodIcons_cache.put("icon_mod_servicehours_25",mod_servicehours_25);
			oodIcons_cache.put("icon_mod_servicerequest_25",mod_servicerequest_25);
			oodIcons_cache.put("icon_mod_signature_25",mod_signature_25);
			oodIcons_cache.put("icon_mod_social_25",mod_social_25);
			oodIcons_cache.put("icon_mod_socialprofile_25",mod_socialprofile_25);
			oodIcons_cache.put("icon_mod_solution_25",mod_solution_25);
			oodIcons_cache.put("icon_mod_specialpricingproduct_25",mod_specialpricingproduct_25);
			oodIcons_cache.put("icon_mod_specialpricingrequest_25",mod_specialpricingrequest_25);
			oodIcons_cache.put("icon_mod_team_25",mod_team_25);
			oodIcons_cache.put("icon_mod_territory_25",mod_territory_25);
			oodIcons_cache.put("icon_mod_transactionitem_25",mod_transactionitem_25);
			oodIcons_cache.put("icon_mod_unknown_25",mod_unknown_25);
			oodIcons_cache.put("icon_mod_user_25",mod_user_25);
			oodIcons_cache.put("icon_mod_vehicle_25",mod_vehicle_25);
		}
		
	}	
}