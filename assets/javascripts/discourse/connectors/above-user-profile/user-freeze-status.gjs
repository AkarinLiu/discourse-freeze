import { eq } from "discourse/truth-helpers";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default <template>
  {{#if @outletArgs.model.frozen_status}}
    {{#if (eq @outletArgs.model.frozen_status.reason "user_deceased")}}
      <div class="alert alert-info freeze-memorial">
        <span class="freeze-memorial__icon">{{dIcon "dove"}}</span>
        <span class="freeze-memorial__text">{{i18n "freeze.memorial_message" username=@outletArgs.model.username}}</span>
      </div>
    {{else}}
      <div class="alert alert-error">
        <div class="freeze-notice__row">
          <span class="freeze-notice__icon">{{dIcon "ban"}}</span>
          <div class="freeze-notice__body">
            <strong>{{i18n "freeze.frozen_notice"}}</strong>
            <span class="freeze-notice__reason">{{@outletArgs.model.frozen_status.reason_label}}</span>
            {{#if @outletArgs.model.frozen_status.frozen_by}}
              <span class="freeze-notice__frozen-by">{{@outletArgs.model.frozen_status.frozen_by}}</span>
            {{/if}}
          </div>
        </div>
      </div>
    {{/if}}
  {{/if}}
</template>
