---
title: "Automatizando o download de imagens do SDSS"
author: nmcardoso
date: 2019-11-11
image: /assets/img/galaxies.jpg
---

# Introdução

Uma das primeiras etapas para resolução de um problema de machine learning é a obtenção dos dados para treinar o modelo. Mas nem sempre os dados estão disponíveis de forma simples. Além disso, como é envolvido grande número de dados, muitas vezes é necessária a obtenção automatizada desses dados. Neste artigo será comentada formas de fazer download de grande quantidade de imagens do SDSS por um script.

<!-- more -->

## Como o SDSS disponibiliza suas imagens?

A forma mais comum de acessar o catálogo de imagens do SDSS é pela página do [SkyServer](https://skyserver.sdss.org/dr15/en/tools/chart/list.aspx), que é uma interface de usuário ([UI](https://en.wikipedia.org/wiki/User_interface)) para obtenção das imagens, ou seja, uma interface entre o servidor e a pessoa na qual o usuário interage com o servidor de forma gráfica. Mas além da interface de usuário, o SDSS disponibiliza uma interface de programação de aplicação ([API](https://en.wikipedia.org/wiki/Application_programming_interface)), que é uma forma do servidor se comunicar diretamente com outro programa.

A API do SDSS está documentada [nesta página](http://skyserver.sdss.org/dr15/en/help/docs/api.aspx). Ela disponibiliza mais dados além de images, mas aqui veremos como usá-la para fazer nosso programa se comunicar diretamente com o servidor do SDSS para obter imagens.

## Como funciona uma API?

Simplificadamente, o funcionamento de uma API é análogo ao de uma função. A diferença é que você não está invocando uma função do seu programa, mas de um outro programa, escrito em outra linguagem e executado em outro computador. Sendo assim, você precisa chamar essa função pela internet.

Mas como é possível executar uma função escrita em outra linguagem e executando em outro computador? Isso é possível porque os pragramas que são projetados para comunicar com outros programas usam um padrão de comunicação. No caso do SDSS, é implementada uma arquitetura de software chamada [REST](https://en.wikipedia.org/wiki/Representational_state_transfer), que é a mais comumente usada para esta finalidade.

Os programas que se comunicam por uma API REST usam o protocolo [HTTP](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol) para trocar informações. Assim, para que um programa executar uma determinada função no servidor, basta que acesse uma [URL](https://en.wikipedia.org/wiki/URL). Cada URL do servidor representa uma função, nela também é possível passar parâmetros. Isso também é chamada de *Rota da API*.

## Mecanismo de uma API

<img src="https://idratherbewritingmedia.com/images/api/restapi_restapi.svg" width="600px" style="max-width:100%;" class="mx-auto d-block">

No exemplo ilustrado pelo diagama acima, vemos um programa escrito em [Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language)) se comunicando com um servidor escrito em [Java](https://en.wikipedia.org/wiki/Java_(programming_language)). Este diagrama mostra as principais caracteristica de uma comunicação REST. Vemos que ela é constituída de dois principais eventos: a requisição (Request) e a resposta (Response). 

Na requisição, vemos que a aplicação acessa uma URI do servidor. A primeira parte da URI `http://coolhomes.api.com` é chamada de [endpoint](https://en.wikipedia.org/wiki/Web_API#Endpoints) e a segunda parte da URI `/home?limit=5` é chamada de rota. Na rota, o que vemos antes da interrogação é o nome da rota e o que vemos depois são os parâmetros. Fazendo uma analogia, a rota é como se fosse uma função. Neste caso seria como se estivéssemos invocando a função home com parâmetro limite igual a 5  `home(limit=5)`.

Da mesma forma, a resposta seria o retorno da função. Neste caso, a resposta retorna uma lista de casas com informações como localização e preço serializada como [JSON](https://en.wikipedia.org/wiki/JSON).

## A API do SDSS

Depois desta breve introdução sobre API's, queremos agora saber como usamos a API do SDSS para obter as imagens. Lendo a documentação do SDSS vemos que devemos usar os seguintes valores para endpoint e rota: 

- **endpoint**: `http://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout`
- **rota**: `/getJpeg`

Além disso, vemos que esta rota aceita os seguintes parâmetros:

- **Ra**: Right Ascention in degrees
- **Dec**: Declination in degrees
- **scale**: Scale of image in arsec per pixel, 0.4 is default
- **height**: in pixels
- **width**: in pixels
- **opt**: a string of characters for overlays on image (details below). This is an optional parameter

Aqui neste exemplo usaremos os 5 primeiros parâmetros, o sexto parâmetro `opt` são as overlays que você pode opcionalmente carregar nas imagens, são as mesmas disponíveis quando se obtem as imagens pelo SkyServer.

## Exemplo de requisições

Para ilustrar nosso problema, vamos fazer algumas **requisições** para API do SDSS para ver qual sua **resposta**.

Imagine que temos 3 objetos identificados pela sua sessão reta e declinação, como na tabela abaixo,  e queiramos obter suas respectivas imagens.

<div class="table-wrapper">
  <table class="table table-striped text-center">
    <thead>
      <tr>
        <th>Objeto</th>
        <th>RA</th>
        <th>DEC</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>1</td>
        <td>19.023342</td>
        <td>-0.014911</td>
      </tr>
      <tr>
        <td>2</td>
        <td>24.398026</td>
        <td>-0.135213</td>
      </tr>
      <tr>
        <td>3</td>
        <td>19.196877</td>
        <td>-0.103266</td>
      </tr>
    </tbody>
  </table>
</div>

Para todos os objetos usaremos `width=180`, `height=180` e `scale=0.3`. A tabela abaixo mostra a URL de **requisição** com os parâmetros que definimos e sua respectiva **resposta**.

<div class="table-wrapper">
  <table class="table table-striped text-center">
    <thead>
      <tr>
        <th>Objeto</th>
        <th>Resposta</th>
        <th>Requisição</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="align-middle">1</td>
        <td class="align-middle"><img src="http://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=19.023342&dec=-0.014911&width=180&height=180&scale=.3"></td>
        <td class="align-middle"><a href="http://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=19.023342&dec=-0.014911&width=180&height=180&scale=.3">http://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=19.023342&dec=-0.014911&width=180&height=180&scale=.3</a></td>
      </tr>
      <tr>
        <td class="align-middle">2</td>
        <td class="align-middle"><img src="http://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=24.398026&dec=-0.135213&width=180&height=180&scale=.3"></td>
        <td class="align-middle"><a href="http://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=24.398026&dec=-0.135213&width=180&height=180&scale=.3">http://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=24.398026&dec=-0.135213&width=180&height=180&scale=.3</a></td>
      </tr>
      <tr>
        <td class="align-middle">3</td>
        <td class="align-middle"><img src="http://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=19.196877&dec=-0.103266&width=180&height=180&scale=.3"></td>
        <td class="align-middle"><a href="http://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=19.196877&dec=-0.103266&width=180&height=180&scale=.3">http://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=19.196877&dec=-0.103266&width=180&height=180&scale=.3</a></td>
      </tr>
    </tbody>
  </table>
</div>

Observando a tabela acima, percebemos que a requisição é composta de dois parâmetros principais: **RA** e **DEC**, e a resposta é uma imagem **jpeg**.

# Metodologia

Agora que já entendemos o mecanismo da API do SDSS, da mesma forma que obtemos imagens de 3 objetos  é bem simples pensar em como implementar um programa que faz download de todos os objetos de um [DataFrame](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.html) do [python](https://en.wikipedia.org/wiki/Python_(programming_language)), por exemplo.

Podemos baixar as imagens que desejamos em dois passos:

- Iterar sobre uma [coleção](https://en.wikipedia.org/wiki/Collection_(abstract_data_type)) de dados (DataFrame, Lista, etc.) e montar as URL's para fazer a requisição.
- Salvar a resposta da API (imagem) no disco.

# Implementação

Primeiro, vamos implementar uma função que recebe os parâmetros aceitos pela rota da API do SDSS e montar nossa URL.

```py
def create_request_url(ra, dec, width=200, height=200, scale=.3):
  ROUTE = 'http://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg'
  return f'{ROUTE}?ra={ra}&dec={dec}&width={width}&height={height}&scale={scale}'
```

A função `create_request_url` possui dois parâmetros obrigatórios: **ra** e **dec**. Os demais são opicionais.

Agora vamos implementar uma função que receba uma URL, faça a *requisição* e salve a *resposta* (imagem) no disco. Para isso, vamos utilizar a biblioteca `requests` do python.

```py
import requests

def download_image(url, filename):
  output_path = '/content/images/'
  resp = requests.get(url)

  if (resp.status_code == 200):
    with open(f'{output_path}/{filename}', 'wb') as f:
      f.write(resp.content)
      print(f'Image {filename} downloaded')
```

A função `download_image` baixa **uma** imagem, que é a resposta da URL acessada. Mas, na maioria das vezes, não queremos baixar apenas uma imagem, mas várias. Então vamos implementar uma terceira função que chama a função acima para cada linha de um `DataFrame` do pandas. 

```py
import pandas as pd

def batch_download(df):
  for index, row in df.iterrows():
    url = create_request_url(row['ra'], row['dec'])
    filename = f'{int(row["id"])}.jpg'
    download_image(url, filename)
```

A função `batch_download` itera sobre um DataFrame e faz chamadas em batelada da função `download_image` até que todos os objetos estejem baixados.

Para ilustrar este exemplo, vamos usar um dataset de amostra com 50 objetos. Estes dados estão num arquivo CSV que contém os dados de RA e DEC de cada objeto. O trecho de código abaixo carrega o dataset e chama a função `batch_download`, nossa função principal.

```py
data = pd.read_csv('https://iagml.github.io/assets/example_data.csv')
batch_download(data)
```

A imagem abaixo mostra as imagens baixadas pelo programa.

<img src="/assets/img/galaxies.jpg" class="d-block mx-auto" width="800px" style="max-width: 100%">

# Jupyter Notebooks

Um exemplo deste código está disponível no Google Colabs e pode ser acessado pelo link abaixo

[Simple SDSS Image Download](https://colab.research.google.com/drive/1tlAH_ZOyezSfHkVTt85aum7n5OgQrCmE) [![Google Colabs](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1tlAH_ZOyezSfHkVTt85aum7n5OgQrCmE)

Abaixo tem outro exemplo um pouco mais complexo, mas com performance muito superior pois utiliza [computação concorrente](https://en.wikipedia.org/wiki/Concurrent_computing) para baixar as imagens. Ou seja, ao invés de baixar imagem por imagem, o programa cria vários [processos paralelos](https://en.wikipedia.org/wiki/Multiprocessing) que baixam as imagens [assincronamente](https://en.wikipedia.org/wiki/Asynchrony_(computer_programming)). 

[SDSS Stamps](https://colab.research.google.com/drive/11aNTyapkYI1drPynZemDG-WhrNPkPMcM) [![Google Colabs](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/11aNTyapkYI1drPynZemDG-WhrNPkPMcM)