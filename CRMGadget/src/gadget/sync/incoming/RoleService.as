package gadget.sync.incoming {

	public class RoleService extends IncomingReadAllService {

		public function RoleService() {
			super({
				name: 'Role Service',
				service: 'Services/cte/RoleService',
				ns1: 'urn:crmondemand/ws/odesabs/role/',
				ns2: 'urn:/crmondemand/xml/role/data',
				urn: 'document/urn:crmondemand/ws/odesabs/role/:RoleReadAll',
				input: 'RoleReadAll_Input',
				output: 'RoleReadAll_Output',
				def:{tag:{
					ListOfRole:{tag:{Role:{
						dao:{
							name:'RoleService',
							copy:{ RoleServiceRoleName:'RoleName' },
							tag:{
								ListOfRoleTranslation:{tag:{RoleTranslation:{
									dao:{
										name:'RoleServiceTrans'
									}
								}}},
								ListOfRecordTypeAccess:{tag:{RecordTypeAccess:{
									dao:{
										name:'RoleServiceRecordTypeAccess'
									}
								}}},
								AccessProfile:{
									cols:[ 'DefaultAccessProfile','OwnerAccessProfile' ]
								},
								ListOfPrivilege:{tag:{Privilege:{
									dao:{
										name:'RoleServicePrivilege'
									}
								}}},
								TabAccessAndOrder:{
									tag:{
										ListOfAvailableTab:{tag:{AvailableTab:{
											dao:{
												self:true,
												name:'RoleServiceAvailableTab'
											}
										}}},
										ListOfSelectedTab:{tag:{SelectedTab:{
											dao:{
												name:'RoleServiceSelectedTab'
											}
										}}}
									}
								},
								ListOfPageLayoutAssignment:{tag:{PageLayoutAssignment:{
									dao:{
										name:'RoleServicePageLayout'
									}
								}}},
								ListOfSearchLayoutAssignment:{tag:{SearchLayoutAssignment:{
									dao:{
										name:'RoleServiceLayout',
										def:{ Layout:'Search' }
									}
								}}},
								ListOfHomepageLayoutAssignment:{tag:{HomepageLayoutAssignment:{
									dao:{
										name:'RoleServiceLayout',
										def:{ Layout:'Home' }
									}
								}}}
							}
						}
					}
				}}}}
			});
		}
	}
}
