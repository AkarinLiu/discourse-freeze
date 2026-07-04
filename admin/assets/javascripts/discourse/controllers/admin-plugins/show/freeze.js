import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class AdminPluginsShowFreezeController extends Controller {
  @service router;

  @tracked searchQuery = "";
  @tracked searchResults = [];
  @tracked selectedUser = null;
  @tracked selectedReason = "";

  get frozenUsers() {
    return this.model?.frozen_users || [];
  }

  get isFreezeDisabled() {
    return !this.selectedUser || !this.selectedReason;
  }

  @action
  searchUsers(event) {
    const q = event.target.value;
    this.searchQuery = q;

    if (q.length < 2) {
      this.searchResults = [];
      return;
    }

    ajax("/freeze/search_users", { data: { q } })
      .then((result) => {
        this.searchResults = result.users;
      })
      .catch(popupAjaxError);
  }

  @action
  selectUser(user) {
    this.selectedUser = user;
    this.searchQuery = `${user.username} (${user.name})`;
    this.searchResults = [];
  }

  @action
  setReason(event) {
    this.selectedReason = event.target.value;
  }

  @action
  freezeUser() {
    if (!this.selectedUser || !this.selectedReason) {
      return;
    }

    ajax("/freeze/create", {
      type: "POST",
      data: {
        user_id: this.selectedUser.id,
        reason: this.selectedReason,
      },
    })
      .then(() => {
        this.selectedUser = null;
        this.selectedReason = "";
        this.searchQuery = "";
        this.router.refresh();
      })
      .catch(popupAjaxError);
  }

  @action
  unfreezeUser(user) {
    ajax("/freeze/revoke", {
      type: "POST",
      data: { user_id: user.user_id },
    })
      .then(() => {
        this.router.refresh();
      })
      .catch(popupAjaxError);
  }

  @action
  clearSelection() {
    this.selectedUser = null;
    this.selectedReason = "";
    this.searchQuery = "";
    this.searchResults = [];
  }
}
