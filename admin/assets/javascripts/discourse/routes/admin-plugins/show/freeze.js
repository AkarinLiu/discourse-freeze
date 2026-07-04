import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class AdminPluginsShowFreezeRoute extends DiscourseRoute {
  model() {
    return ajax("/freeze/list");
  }
}
