---
layout: default
---

<div style="min-height:500px">
<!-- This loops through the paginated posts -->
{% assign tag = page.url | basename %}
{% for post in site.tags[ tag ] %}
  <h2 class="mt-3"><a href="{{ post.url }}">{{ post.title }}</a></h2>
  <p class="author">
    <span class="date">{{ post.date | date: site.date_format }}</span>
  </p>
  <div class="content">
    {{ post.excerpt }}
  </div>
  <a href="{{ post.url }}" class="btn btn-info">More</a>
{% endfor %}
</div>

