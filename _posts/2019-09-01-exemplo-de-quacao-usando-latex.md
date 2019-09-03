---
title: "Exemplo de equação usando LaTeX"
author: nmcardoso
date: 2019-09-01 09:45:21 -0300
image: /assets/img/latex-eq.png
---

Um exemplo de equações

$$
  \large
  E[g^2]_t = \beta E[g^2]_{t-1} + (1 - \beta)(\frac{\delta C}{\delta w})^2
$$

$$
  \large
  w_t = w_{t-1} - \frac{n}{\sqrt{E[g^2]_t}} \frac{\delta C}{\delta w}
$$

E[g] — moving average of squared gradients. dC/dw — gradient of the cost function with respect to the weight. n — learning rate. Beta — moving average parameter (good default value — 0.9)