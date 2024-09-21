# Projeto Parcial de Processamento Gráfico - Ray Tracing
Foi desenvolvido pelos integrantes do grupo uma aplicação de visualização de imagens utilizando a técnica de Ray tracing, com o objetivo de gerar imagens realistas simulando a interação da luz com diferentes materias. O projeto visa a criação de uma cena composta por pelo menos cinco objetos com materiais variados, além de movimentos na câmera e nos objetos para a geração de diferentes perspectivas.
A implementação foi realizada na linguagem Julia.

## Feito por
- Luis Felipi Cruz de Souza [@LuisFSouza](https://github.com/LuisFSouza)
- Ryan de Melo Andrade [@MasteryRyge](https://github.com/MasteryRyge)
- Felipe Bonadia [@FelipeBonadia](https://github.com/FelipeBonadia)
- Giovana Maciel dos Santos [@GiovanaMaciel](https://github.com/GiovanaMaciel)

## Descrição das Cenas Geradas
A cena gerada contém um boneco de neve e algumas esferas de vários materias sobre o chão em sua volta para decoração. Para a construção, foi utilizado diversas esferas de diferentes materiais, tamanhos e cores. 
Para fazer o boneco de neve, foram usadas várias esferas de material lambertiano de várias cores (branco, laranja e preto).
Ao lado esquerdo do boneco, há uma esfera de metal de cor prata. Entre o boneco e essa esfera, posicionado mais atrás, há uma esfera de material lambertiano de cor verde. 
Ao lado direito do boneco, há uma esferera de material dielétrico. Entre o boneco e essa esfera, posicionado mais atrás, há uma esfera de material metal, de cor prata, com borramento.
Para fazer o chão, foi utilizado uma esfera de material lambertiano, de cor cinza clara, e de raio grande

![raytracing1](https://github.com/user-attachments/assets/21258678-0830-4fea-b0bc-69f5f3265bc8)

Para gerar a segunda imagem, trocamos a esfera de decoração verde (que era de material lambertiano) de posição com a esfera de decoração de material dielétrico, e movemos a camêra para ter uma visão como se tivesse olhando mais da direita.

Imagem cena 2

### Esferas utilizadas
* <strong>Chão</strong>: Uma grande esfera de raio 100.0, posicionada sob a figura principal. O material do chão é lambertiano (difuso), com cor cinza clara (RGB(0.66, 0.66, 0.66)).

* <strong>Corpo do Boneco de Neve</strong>: Composto por três esferas de material lambertiano:

  <strong>Esfera Inferior</strong>: Raio 0.8, cor branca (RGB(1.0, 1.0, 1.0)), posição centralizada em Vec3(0.0, -0.1, -1.0).

  <strong>Esfera do Meio</strong>: Raio 0.6, cor branca, posição Vec3(0.0, 0.7, -1.0).

  <strong>Esfera Superior</strong>: Raio 0.4, cor branca, posição Vec3(0.0, 1.4, -1.0).

* <strong>Olhos</strong>:
  
  <strong>Olho Esquerdo</strong>: Uma esfera preta (RGB(0.0, 0.0, 0.0)), com raio 0.05, posicionada em Vec3(-0.2, 1.6, -0.75). Material lambertiano.

  <strong>Olho Direito</strong>: Uma esfera preta de mesmas dimensões e material, em Vec3(0.2, 1.6, -0.75).

* <strong>Nariz (bico)</strong>: Composto por duas pequenas esferas laranjas (RGB(0.901, 0.341, 0.160)), uma com raio 0.05 em Vec3(0.0, 1.5, -0.6) e outra com raio 0.02 em Vec3(0.0, 1.5, -0.55). Material lambertiano.

* <strong>Esfera 1 (que está na direita do boneco, mais atrás)</strong>: Sua posição é Vec3(1.5, 0.0, -3.0), e possui raio 0.5. Seu material é metálico (Metal), com uma cor metálica prateada (RGB(0.8, 0.8, 0.8)) e coeficiente de rugosidade de 0.3 (mais opaco).

* <strong>Esfera 2 (que está na esquerda do boneco, mais a frente)</strong>: Sua posição é Vec3(-2.0, 0.0, -1.0), e possui raio 0.5. Seu material é metálico (Metal), com uma cor prata (RGB(0.7529, 0.7529, 0.7529)) e coeficiente de rugosidade de 0.0 (superfície refletiva perfeita).

* <strong>Esfera 3 (que está na direita do boneco, mais a frente)</strong>: Sua posição é Vec3(2.0, 0.0, -1.0) (posteriormente movida para Vec3(-1.5, 0.0, -3.0)), e possui raio 0.5. Seu material é dielétrico, com um índice de refração de 1.5 (vidro).

* <strong>Esfera 4 (que está na esquerda do boneco, mais atras)</strong>: Sua posição é Vec3(-1.5, 0.0, -3.0) (posteriormente movida para Vec3(2.0, 0.0, -1.0)), e possui raio 0.5. Seu material é lambertiano, com cor verde (RGB(0.0, 0.9, 0.0)).

### Camera
* Na primeira imagem, a câmera está posicionada olhando da posição (0.0, 2.0, 2.0)
* Na segunda imagem, a câmera está posicionada olhando da posição (4.0, 2.0, 2.0)

### WCS
Consideramos que o eixo X é a horizontal, o eixo Y é a vertical, e o eixo Z a profundidade, apontando para fora da tela.

## Setup do Projeto
### Pré-requisitos
Antes de executar o projeto, siga os seguintes passos:

1. **Julia**: O projeto utiliza a linguagem Julia. Faça o download em [https://julialang.org/downloads/](https://julialang.org/downloads/) e baixe a versão mais recente. Siga as instruções de instalação fornecidas no site para o seu sistema operacional.

### Execução do Projeto
Para executar o projeto e gerar as imagens, siga os seguintes passos:

1. **Clone o repositório**: Clone este repositório em sua máquina local utilizando o Git
```
git clone https://github.com/LuisFSouza/raytracing.git
```

2. **Abra o terminal na pasta obtida**: Abra o terminal na pasta obtida pela clonagem, que contém o conteúdo do projeto

3. **Abra o terminal julia**: Abra o terminal julia usando o seguinte comando no terminal
```
julia
```

4. **Entre no modo de pacotes do julia**: Para entrar no modo de pacotes do julia, aperte a tecla ```]```


5. **Instale a biblioteca Images**: Instale a biblioteca do julia para imagens usando o seguinte comando
```
add Images
```

6. **Saia do terminal julia**: Aperte ```CTRL + D``` Para sair do terminal julia e voltar para o terminal onde estava

7. **Rode a implementação**: Digite o seguinte comando para rodar a implementação. Os resultados obtidos serão colocados dentro da pasta Imagens
```
julia ./src/main.jl
```

### Observações
Dentro da pasta Imagens já estão as duas imagens geradas pelo grupo em full hd. 

### Referências
Para o desenvolvimento deste projeto, utilizamos como base a seguinte playlist: [Playlist](https://www.youtube.com/watch?v=LlNaI6upK94&list=PL5TJqBvpXQv4cAynxaIyclmpZ95g-gtqQ&index=4)

