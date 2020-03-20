---
title: "Automatizando o download de imagens do SDSS"
author: nmcardoso
date: 2019-11-11
image: /assets/uploads/galaxy_grid.jpg
---

# Introdução

Uma das primeiras etapas para resolução de um problema de machine learning é a obtenção dos dados para treinar o modelo. Mas nem sempre os dados estão disponíveis de forma simples. Além disso, como é envolvido grande número de dados, muitas vezes é necessária a obtenção automatizada desses dados. Neste artigo será comentada formas de fazer download de grande quantidade de imagens do SDSS por um script.

<!--more-->

## Como o SDSS disponibiliza suas imagens?

A forma mais comum de acessar o catálogo de imagens do SDSS é pela página do [SkyServer](https://skyserver.sdss.org/dr15/en/tools/chart/list.aspx), que é uma interface gráfica de usuário ([GUI](https://en.wikipedia.org/wiki/Graphical_user_interface)), ou seja, um método onde há interação do usuário com o sistema de forma visual. Mas além da interface de usuário, o SDSS disponibiliza uma interface de programação de aplicação ([API](https://en.wikipedia.org/wiki/Application_programming_interface)), que é uma forma do [servidor](https://en.wikipedia.org/wiki/Server_(computing)) se comunicar diretamente com outro programa ([cliente](https://en.wikipedia.org/wiki/Client_(computing))).

A API do SDSS está documentada [nesta página](http://skyserver.sdss.org/dr15/en/help/docs/api.aspx). Ela disponibiliza mais dados além de images, mas aqui veremos como usá-la para obter imagens.

## Como funciona uma API?

Simplificadamente, o funcionamento de uma API é análogo ao de uma função. A diferença é que você não está invocando uma função do seu programa, mas de um outro programa, escrito em outra linguagem e executado em outro computador. Sendo assim, você precisa chamar essa função pela internet.

*Mas como é possível executar uma função escrita em outra linguagem e executando em outro computador?* Isso é possível porque os programas que são projetados para comunicar com outros programas usam um padrão de comunicação. No caso do SDSS, é implementada uma arquitetura de software chamada [REST](https://en.wikipedia.org/wiki/Representational_state_transfer), que é uma das mais comuns usadas para esta finalidade.

Os programas que se comunicam por uma API REST usam o protocolo [HTTP](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol) para trocar informações. Assim, para que um programa executar uma determinada função no servidor, basta que acesse uma [URL](https://en.wikipedia.org/wiki/URL). Cada URL do servidor representa uma função, que também pode ser chamada de [endpoint](https://en.wikipedia.org/wiki/Web_API#Endpoints).

## Mecanismo de uma API

<img src="https://idratherbewritingmedia.com/images/api/restapi_restapi.svg" width="600px" style="max-width:100%;" class="mx-auto d-block">

No exemplo ilustrado pelo diagama acima, vemos um programa escrito em [Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language)) se comunicando com um servidor escrito em [Java](https://en.wikipedia.org/wiki/Java_(programming_language)). Este diagrama mostra as principais características de uma comunicação REST. Vemos que ela é constituída de dois principais eventos: a **requisição** (Request) e a **resposta** (Response). 

Na requisição, observamos que a aplicação acessa uma URI do servidor. A primeira parte da URI `http://coolhomes.api.com` é chamada de caminho base (*base path*) e a segunda parte `/home?limit=5` é a *rota*. Na rota, o que vemos antes da interrogação é seu nome e depois são seus parâmetros. O *endpoint* é o ponto final de um canal de comunicação, ou seja, é a URL acessada para executar alguma função no servidor. No diagrama acima, o *endpoint* é `http://coolhomes.api.com/home`. 

Se considerarmos que, ao acessar uma URL, o servidor executa uma função específica, então um *endpoint* é o endereço de uma função na rede. Desta maneira, acessar a URL `http://coolhomes.api.com/home?limit=5` seria como invocar uma função *home* com o parâmetro *limit* igual a 5: `home(limit=5)`.

Uma API pode retornar diversos tipos de repostas (que é o retorno da função executada internamente no servidor). Na arquitetura REST, os objetos retornados são comumente serializados como [JSON](https://en.wikipedia.org/wiki/JSON), que é a representação do objeto na forma de uma *string*. Desta forma, o cliente consegue receber e interpretar tipos de dados arbitrários independentemente da linguagem de programação utilizada.

<div class="alert alert-info">
  Alguns autores definem <b>endpoint</b> como a função executada internamente pelo servidor quando recebe a chamada de alguma rota. Mas, considerando que um <i>endpoint</i> é o ponto terminal de um canal de comunicação, ambas as definições podem ser usadas, pois, do lado o cliente, o ponto final é a URL e, do lado do servidor, é a função.
</div>

Além disso, notamos que o fluxo de comunicação entre dois sistemas é: o cliente acessa uma URL, isso faz com que o servidor execute a função relacionada àquela rota e retorne a resposta para o cliente.

## A API do SDSS

Depois desta breve introdução sobre API's, queremos agora saber como usamos a API do SDSS para obter as imagens. Lendo a documentação do SDSS, vemos que devemos usar o seguinte endereço para o  *endpoint*:

- **endpoint**: `http://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getJpeg`

Além disso, vemos que esta URL aceita os seguintes parâmetros:

<div class="table-wrapper">
  <table class="table table-striped text-center">
    <thead>
      <tr>
        <th>Parâmetro</th>
        <th>Descrição</th>
        <th style="white-space: nowrap;">Valor padrão</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>ra</td>
        <td>Ascensão Reta (em graus)</td>
        <td>-</td>
      </tr>
      <tr>
        <td>dec</td>
        <td>Declinação (em graus)</td>
        <td>-</td>
      </tr>
      <tr>
        <td>scale</td>
        <td>Escala da imagem (em arsec por pixel)</td>
        <td>0.4</td>
      </tr>
      <tr>
        <td>height</td>
        <td>Altura da imagem (em pixels)</td>
        <td>512</td>
      </tr>
      <tr>
        <td>width</td>
        <td>Largura da imagem (em pixels)</td>
        <td>512</td>
      </tr>
      <tr>
        <td>opt</td>
        <td>Uma string com as overlays que serão carregadas sobre a imagem</td>
        <td>-</td>
      </tr>
    </tbody>
  </table>
</div>

Os parâmtros **ra** e **dec** são obrigatórios, já os demais são opcionais, visto que têm um valor padrão.

Neste exemplo, usaremos os 5 primeiros parâmetros, o sexto parâmetro `opt` são as overlays que podem ser opcionalmente carregadas nas imagens, são as mesmas overlays disponíveis quando se obtém as imagens pelo site do SkyServer.

## Exemplo de requisições

Para ilustrar nosso problema, vamos fazer algumas **requisições** para API do SDSS para ver qual sua **resposta**.

Imagine que temos 3 objetos identificados pela sua ascensão reta e declinação, como na tabela abaixo,  e queiramos obter suas respectivas imagens.

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
        <td class="align-middle"><img src="https://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=19.023342&dec=-0.014911&width=180&height=180&scale=.3"></td>
        <td class="align-middle"><a href="https://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=19.023342&dec=-0.014911&width=180&height=180&scale=.3">https://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=19.023342&dec=-0.014911&width=180&height=180&scale=.3</a></td>
      </tr>
      <tr>
        <td class="align-middle">2</td>
        <td class="align-middle"><img src="https://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=24.398026&dec=-0.135213&width=180&height=180&scale=.3"></td>
        <td class="align-middle"><a href="https://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=24.398026&dec=-0.135213&width=180&height=180&scale=.3">https://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=24.398026&dec=-0.135213&width=180&height=180&scale=.3</a></td>
      </tr>
      <tr>
        <td class="align-middle">3</td>
        <td class="align-middle"><img src="https://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=19.196877&dec=-0.103266&width=180&height=180&scale=.3"></td>
        <td class="align-middle"><a href="https://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=19.196877&dec=-0.103266&width=180&height=180&scale=.3">https://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg?ra=19.196877&dec=-0.103266&width=180&height=180&scale=.3</a></td>
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

<div class="alert alert-info">
  Aqui usaremos a linguagem <b>Python</b> para escrever nosso programa, mas ele poderia ser escrito em qualquer linguagem de programação que tenha uma biblioteca de abstração da camada de rede para enviar e receber pacotes usando o protocolo HTTP.
</div>

# Implementação

Primeiro, vamos implementar uma função que recebe os parâmetros aceitos pela rota da API do SDSS e montar nossa URL.

```py
def create_request_url(ra, dec, width=200, height=200, scale=.3):
  ENDPOINT = 'http://skyserver.sdss.org/dr15/SkyServerWS/ImgCutout/getjpeg'
  return f'{ENDPOINT}?ra={ra}&dec={dec}&width={width}&height={height}&scale={scale}'
```

A função `create_request_url` possui dois parâmetros obrigatórios: **ra** e **dec**. Os demais são opicionais.

Agora vamos implementar uma função que receba uma URL, faça a *requisição* e salve a *resposta* (imagem) no disco. Para isso, vamos utilizar a biblioteca [requests](https://requests.readthedocs.io/en/master/), que é responsável pelo envio e recebimento de pacotes através da rede.

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

A função `batch_download` itera sobre um DataFrame e chama a função `download_image` para cada objeto da coleção recebida como parâmetro.

Para ilustrar este exemplo, vamos usar um dataset de amostra com 50 objetos. Estes dados estão num arquivo CSV que contém informações de RA e DEC de cada objeto. O trecho de código abaixo carrega o dataset e chama a função `batch_download`, nossa função principal.

```py
data = pd.read_csv('https://iagml.github.io/assets/example_data.csv')
batch_download(data)
```

A figura abaixo mostra as imagens baixadas pelo programa.

<img src="/assets/uploads/galaxy_grid.jpg" class="d-block mx-auto" width="860px" style="max-width: 100%">

# Jupyter Notebooks

Um exemplo deste código está disponível no Google Colabs e pode ser acessado pelo link abaixo

[Simple SDSS Image Download](https://colab.research.google.com/drive/1tlAH_ZOyezSfHkVTt85aum7n5OgQrCmE) [![Google Colabs](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1tlAH_ZOyezSfHkVTt85aum7n5OgQrCmE)

Abaixo tem outro exemplo um pouco mais complexo, mas com performance muito superior pois utiliza [computação concorrente](https://en.wikipedia.org/wiki/Concurrent_computing) para baixar as imagens. Isto é, ao invés de baixar as imagens sequencialmente, esperando uma imagem baixar para depois baixar a próxima, o programa cria vários [processos paralelos](https://en.wikipedia.org/wiki/Multiprocessing) que baixam várias imagens [simultaneamente](https://en.wikipedia.org/wiki/Asynchrony_(computer_programming)). 

[SDSS Stamps](https://colab.research.google.com/drive/11aNTyapkYI1drPynZemDG-WhrNPkPMcM) [![Google Colabs](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/11aNTyapkYI1drPynZemDG-WhrNPkPMcM)