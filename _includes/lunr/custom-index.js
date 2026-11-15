{%- comment -%}
  Runs inside the theme's index loop, before each document is added: index
  only the pages of the language the reader is on, so a Russian search does
  not land on English pages and the reverse. relUrl has no baseurl; the
  location does.
{%- endcomment -%}
if ((docs[i].relUrl.indexOf('/en/') === 0) !==
    (window.location.pathname.indexOf('{{ "/en/" | relative_url }}') === 0)) {
  continue;
}
