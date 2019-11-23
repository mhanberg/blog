---
layout: default
---

<form id="my-form">
  <!-- Include any fields you need -->
  <label for="email">Email</label>
  <input id="email" type="email" name="email" value="" required />
  <button type="submit">Submit</button>
</form>

<script>
  window.sk=window.sk||function(){(sk.q=sk.q||[]).push(arguments)};

  sk("form", "init", {
    site: "4d56b852b344",   // found under the Settings tab
    form: "beginner-elixir",  // the key used in statickit.json
    element: "#my-form",
    onSuccess: function(config) {
    var h = config.h;
    var form = config.form;
    var replacement = h('div.success-message', 'Thank you for joining!');
    form.parentNode.replaceChild(replacement, form);
  },
  });
</script>
