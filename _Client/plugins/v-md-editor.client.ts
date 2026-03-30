import { defineNuxtPlugin } from '#app';
import VueMarkdownEditor from '@kangc/v-md-editor';
import '@kangc/v-md-editor/lib/style/base-editor.css';
import vuepressTheme from '@kangc/v-md-editor/lib/theme/vuepress.js';
import '@kangc/v-md-editor/lib/theme/style/vuepress.css';

import VMdPreview from '@kangc/v-md-editor/lib/preview';
import '@kangc/v-md-editor/lib/style/preview.css';

import Prism from 'prismjs';

export default defineNuxtPlugin((nuxtApp) => {
  VueMarkdownEditor.use(vuepressTheme, {
    Prism,
  });
  VMdPreview.use(vuepressTheme, {
    Prism,
  });

  nuxtApp.vueApp.use(VueMarkdownEditor);
  nuxtApp.vueApp.use(VMdPreview);
});
