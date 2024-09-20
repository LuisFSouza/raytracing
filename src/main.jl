using Images
include("utils.jl")

#Aqui estão algumas configurações das dimensões das imagens que serão geradas
#Razão de aspecto
razaoDeAspecto = 16/9
#Largura da imagem
largura = 1920;
#Altura da imagem
altura = trunc(Int64, largura/razaoDeAspecto);

#=Essa função gera uma imagem usuando raytracing, 
a partir de uma camera, uma lista de objetos na cena,
o caminho para salvar a imagem, a quantidade de raios por pixel para o anti aliasing,
e a quantidade maxima de raios refletidos na cena
=#
function gerarImagemRayTracing(camera::Camera, listaObjetosCena::ListaObjetosDaCena, caminhoImagem, qtdd_raios_por_pixel, qtdd_max_raios_refletidos_cena)
    imagem = RGB.(zeros(altura, largura));
    #Percorrendo os pixeis da imagem atribuindo suas cores, junto a aplicação do anti-aliasing
    for j=1: altura
        for i=1: largura
            cor = RGB(0.0, 0.0, 0.0)
            for p = 1: qtdd_raios_por_pixel
                u = (i-1 + rand())/(largura-1)
                v = 1.0 - (j-1 + rand())/(altura-1)
                cor += corDoRaio(criaRaio(camera, u, v), listaObjetosCena, qtdd_max_raios_refletidos_cena)
            end
            imagem[j,i] = garanteIntervaloCor(cor/qtdd_raios_por_pixel);
        end
    end
    save(caminhoImagem, correcaoGama.(imagem))
end

#=
Criando um mundo com varios objetos
=#
raioChao = 100.0
chao = Esfera(Vec3(0.0, -raioChao - 0.5, -1.0), raioChao,Lambertiano(RGB(0.66, 0.66, 0.66)))
esferaBaixo = Esfera(Vec3(0.0, -0.1, -1.0), 0.8, Lambertiano(RGB(1.0, 1.0, 1.0)))
esferaMeio = Esfera(Vec3(0.0, 0.7, -1.0), 0.6, Lambertiano(RGB(1.0, 1.0, 1.0)))
esferaCima = Esfera(Vec3(0.0, 1.4, -1.0), 0.4, Lambertiano(RGB(1.0, 1.0, 1.0)))
olhoEsquerdo = Esfera(Vec3(-0.2, 1.6, -0.75), 0.05, Lambertiano(RGB(0.0, 0.0, 0.0)))
olhoDireito = Esfera(Vec3(0.2, 1.6, -0.75), 0.05, Lambertiano(RGB(0.0, 0.0, 0.0)))
bico1 = Esfera(Vec3(0.0, 1.5, -0.6), 0.05, Lambertiano(RGB(0.901, 0.341, 0.160)))
bico2 = Esfera(Vec3(0.0, 1.5, -0.55), 0.02, Lambertiano(RGB(0.901, 0.341, 0.160)))
esfera1 = Esfera(Vec3(1.5, 0.0, -3.0), 0.5, Metal(RGB(0.8, 0.8,0.8), 0.3))
esfera2 = Esfera(Vec3(-2.0, 0.0, -1.0), 0.5, Metal(RGB(0.7529, 0.7529,0.7529), 0.0))
esfera3 = Esfera(Vec3(2.0, 0.0, -1.0), 0.5, Dieletrico(1.5))
esfera4 = Esfera(Vec3(-1.5, 0.0, -3.0), 0.5, Lambertiano(RGB(0.0, 0.9, 0.0)))
mundo = ListaObjetosDaCena()
push!(mundo, chao)
push!(mundo, esferaBaixo)
push!(mundo, esferaMeio)
push!(mundo, esferaCima)
push!(mundo, olhoDireito)
push!(mundo, olhoEsquerdo)
push!(mundo, bico1)
push!(mundo, bico2)
push!(mundo, esfera1)
push!(mundo, esfera2)
push!(mundo, esfera3)
push!(mundo, esfera4)

#Criando a camera
camera1 = Camera(90, Vec3(0.0, 1.0, 0.0), Vec3(0.0, 2.0, 2.0), Vec3(0.0, 0.0, -1.0))
#Gerando imagem usando ray tracing a partir da camera e o mundo criado
gerarImagemRayTracing(camera1, mundo, "./Imagens/raytracing1.png", 100, 50)
#Movendo a camera e alguns objetos
camera1 = Camera(90, Vec3(0.0, 1.0, 0.0), Vec3(4.0,2.0, 2.0), Vec3(0.0, 0.0, -1.0))
esfera3.centro = Vec3(-1.5, 0.0, -3.0)
esfera4.centro = Vec3(2.0, 0.0, -1.0)
#Gerando a outra imagem
gerarImagemRayTracing(camera1, mundo, "./Imagens/raytracing2.png", 100, 50)