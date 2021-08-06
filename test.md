---
test: "ooxx"
title: "yes"
---
test: {{ page.test }}
test: {{ test }}
{% if page.test == "ooxx" %}active{% endif %}
