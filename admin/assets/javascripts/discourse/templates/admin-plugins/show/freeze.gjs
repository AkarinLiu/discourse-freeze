import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";

export default <template>
  <div class="freeze-admin">
    {{!-- Freeze a user --}}
    <div class="freeze-admin__actions">
      <h3>{{i18n "freeze.freeze_user"}}</h3>

      <div class="freeze-admin__search">
        <input
          type="text"
          value={{@controller.searchQuery}}
          placeholder={{i18n "freeze.search_placeholder"}}
          {{on "input" @controller.searchUsers}}
        />

        {{#if @controller.searchResults.length}}
          <div class="freeze-admin__search-results">
            {{#each @controller.searchResults as |user|}}
              <button type="button" {{on "click" (fn @controller.selectUser user)}}>
                {{user.username}}
                {{#if user.name}}
                  ({{user.name}})
                {{/if}}
              </button>
            {{/each}}
          </div>
        {{/if}}
      </div>

      {{#if @controller.selectedUser}}
        <div class="freeze-admin__selected-user">
          <span class="username">{{@controller.selectedUser.username}}</span>

          <select {{on "change" @controller.setReason}}>
            <option value="">{{i18n "freeze.select_reason"}}</option>
            <option value="account_stolen">
              {{i18n "freeze.reason.account_stolen"}}
            </option>
            <option value="user_deceased">
              {{i18n "freeze.reason.user_deceased"}}
            </option>
          </select>

          <DButton
            @icon="lock"
            @label="freeze.freeze_button"
            @action={{@controller.freezeUser}}
            @disabled={{@controller.isFreezeDisabled}}
            class="btn-danger"
          />

          <DButton
            @icon="times"
            @label="cancel"
            @action={{@controller.clearSelection}}
            class="btn-default"
          />
        </div>
      {{/if}}
    </div>

    {{!-- Frozen users list --}}
    <div class="freeze-admin__list">
      <h3>{{i18n "freeze.frozen_users"}}</h3>

      {{#if @controller.frozenUsers.length}}
        <table>
          <thead>
            <tr>
              <th>{{i18n "freeze.username"}}</th>
              <th>{{i18n "freeze.column_reason"}}</th>
              <th>{{i18n "freeze.frozen_by"}}</th>
              <th>{{i18n "freeze.frozen_at"}}</th>
              <th>{{i18n "freeze.actions"}}</th>
            </tr>
          </thead>
          <tbody>
            {{#each @controller.frozenUsers as |user|}}
              <tr>
                <td>{{user.username}}</td>
                <td>{{user.reason_label}}</td>
                <td>{{user.frozen_by}}</td>
                <td>{{user.frozen_at}}</td>
                <td>
                  <DButton
                    @icon="unlock"
                    @label="freeze.unfreeze_button"
                    @action={{fn @controller.unfreezeUser user}}
                    class="btn-default"
                  />
                </td>
              </tr>
            {{/each}}
          </tbody>
        </table>
      {{else}}
        <p>{{i18n "no_results"}}</p>
      {{/if}}
    </div>
  </div>
</template>
