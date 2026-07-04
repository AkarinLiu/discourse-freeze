import { withPluginApi } from "discourse/lib/plugin-api";

const PLUGIN_ID = "discourse-freeze";

export default {
  name: "freeze-admin-plugin-configuration-nav",

  initialize(container) {
    const currentUser = container.lookup("service:current-user");
    if (!currentUser?.admin) {
      return;
    }

    withPluginApi((api) => {
      api.setAdminPluginIcon(PLUGIN_ID, "snowflake");
      api.addAdminPluginConfigurationNav(PLUGIN_ID, [
        {
          label: "freeze.title",
          route: "adminPlugins.show.freeze",
          description: "freeze.description",
        },
      ]);
    });
  },
};
