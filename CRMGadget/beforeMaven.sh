#bin/bash

echo Replacing Icons for Flexmojos
sed -i.bak 's,<image16x16>/assets/smallIcon.png</image16x16>,,g' src/CRMGadget-app.xml
sed -i.bak 's,<image32x32>/assets/mediumIcon.png</image32x32>,,g' src/CRMGadget-app.xml
sed -i.bak 's,<image48x48>/assets/bigIcon.png</image48x48>,,g' src/CRMGadget-app.xml
sed -i.bak 's,<image128x128>/assets/biggestIcon.png</image128x128>,,g' src/CRMGadget-app.xml
#Here some more modificationsfor unit testing
echo Replacing parts of sources for external compiler
sed -i.bak 's,import org.flexunit.listeners.UIListener;,,g' src/Tests.mxml
sed -i.bak 's,core.addListener(new UIListener(uiListener));,,g' src/Tests.mxml
sed -i.bak 's,<adobe:TestRunnerBase id="uiListener" width="100%" height="100%"  />,,g' src/Tests.mxml
sed -i.bak 's,<mx:Label text="{i18n._("GLOBAL_SEARCH")}"/>,,g' src/ActivityUserList.mxml