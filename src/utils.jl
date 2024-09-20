import LinearAlgebra.cross
import Base.push!
import Base.*

#= 
Tipo abstrato
Para os materiais
=#
abstract type Material
end
#= 
Tipo abstrato
Para os objetos da cena
=#
abstract type ObjetoDaCena
end

#Structs dos materiais
#Struct do metal
struct Metal <: Material
    #Atributos do material metal
    #Cor(albedo)
    cor::RGB
    #Grau de borramento
    fuzzy:: Float64
end
#Struct do dieletrico
struct Dieletrico <:Material
    #Atributos do material dieletrico
    #Indice de refração
    indiceDeRefracao::AbstractFloat
end
#Struct do lambertiano
struct Lambertiano <: Material
    #Atributos do material lambertiano
    #Cor (albedo)
    cor:: RGB
end

#Alias de tipo = Novo nome para o mesmo tipo
#Neste caso, chamamos de Vec3 um vetor unidimensional de float
const Vec3{T <: AbstractFloat} = Array{T, 1}

#Função que constrói o vetor, retorna um vetor com as coordenadas x,y e z
function Vec3{T}(x::T, y::T, z::T) where T
    return [x, y, z]
end

#Construtor de conveniência do vetor
function Vec3(x::T,y::T,z::T) where T
    Vec3{T}(x,y,z)
end

#Função que calcula a norma do vetor antes de passar a raiz
function normaSemRaiz(vetor::Vec3)
    return sum(map(valor->valor^2, vetor))
end

#Função que calcula o produto escalar entre dois vetores
function produtoEscalar(vetor1::Vec3, vetor2::Vec3)
    return sum(vetor1 .* vetor2)
end

#Função que calcula o produto vetorial entre dois vetores
function produtoVetorial(vetor1::Vec3, vetor2::Vec3)
    return cross(vetor1, vetor2)
end

#Função que calcula a norma de um vetor
function norma(vetor::Vec3)
    return sqrt(normaSemRaiz(vetor));
end

#Função que normaliza um vetor
function vetorUnitario(vetor::Vec3)
    return vetor/norma(vetor)
end

#Struct que representa um raio
struct Raio{T <: AbstractFloat}
    #Atributos do raio 
    #Origem do raio
    origem::Vec3{T};
    #Direção do raio
    direcao::Vec3{T};

    #Construtor da struct
    function Raio{T}(origem::Vec3{T}, direcao::Vec3{T}) where T
        #Padronizar a direção normalizada para criar o raio
        new(origem, vetorUnitario(direcao))
    end
end

#Construtor de conveniência do raio
function Raio(origem::Vec3{T}, direcao::Vec3{T}) where T
    Raio{T}(origem, direcao)
end

#Struct que representa um toque do raio a cena, armazena informações de onde o raio tocou a cena
mutable struct Toque{T <: AbstractFloat}
    #Ponto de intersecção
    ponto_interseccao::Vec3{T}
    #A distância do ponto de origem do raio até onde o raio atinge a esfera
    t::T
    #Normal
    normal::Vec3{T}
    #Orientação da face
    orientacaoDaFace::Bool
    #Material tocado
    material::Material

    #Construtor da struct
    function Toque{T}(ponto_interseccao::Vec3{T}, t::T, normal::Vec3{T}, material=Metal(RGB(0.0, 0.0, 0.0), 0.0)) where T <: AbstractFloat
        new(ponto_interseccao, t, normal, false, material)
    end
end

#Construtor de conveniência do toque
function Toque() 
    return Toque{Float64}(Vec3(0.0, 0.0, 0.0), 0.0 , Vec3(0.0, 0.0, 0.0))
end


#Struct que representa uma lista de objetos da cena
struct ListaObjetosDaCena <: ObjetoDaCena
    #Atributos
    #Vetor de objetos na cena
    objetos::Vector{ObjetoDaCena}

    #Construtor da struct
    function ListaObjetosDaCena(objetos::Vector{ObjetoDaCena})
        new(objetos)
    end
end

#Construtor de conveniência para a lista de objetos da cena (criar lista de objetos vazia)
function ListaObjetosDaCena()
    return ListaObjetosDaCena(Vector{ObjetoDaCena}())
end

#Inserir um objeto na cena
function push!(listaObjetosCena::ListaObjetosDaCena, objeto:: ObjetoDaCena)
    push!(listaObjetosCena.objetos, objeto)
end

#Struct que representa uma esfera
mutable struct Esfera{T <: AbstractFloat} <: ObjetoDaCena
    #Atributos da esfera
    #Centro da esfera
    centro::Vec3{T}
    #Raio da esfera
    raio::T
    #Material da esfera
    material::Material

    #Construtor da struct
    function Esfera{T}(centro::Vec3, raio::T, material::Material) where T
        new(centro,raio, material)
    end
end
#Construtor de conveniência da esfera
function Esfera(centro::Vec3, raio::T, material::Material) where T
    Esfera{T}(centro, raio, material)
end


#=
Essa função verifica se um raio atingiu uma esfera,
modificando o parametro toque com as informações do toque caso tenha ocorrido
Retorna verdadeiro se atingiu a esfera, e falso se não atingiu;
=#
function tocou!(esfera::Esfera, raio::Raio, toque::Toque, t_min, t_max)
    #Bhaskara para verificar se tocou a esfera
    a = normaSemRaiz(raio.direcao)
    origemMenosCentro = raio.origem - esfera.centro
    metadeB = produtoEscalar(raio.direcao, origemMenosCentro)
    c = normaSemRaiz(origemMenosCentro) - esfera.raio^2
    discriminante = metadeB*metadeB - a*c;
    if (discriminante < 0)
        #Não bateu na esfera
        return false
    else
        raizDoDiscriminante = sqrt(discriminante)
        raiz = (-metadeB - raizDoDiscriminante)/a
        if(raiz < t_min || raiz > t_max)
            raiz = (-metadeB + raizDoDiscriminante)/a
            if(raiz < t_min || raiz > t_max)
                return false
            end
        end
        #Adicionar ao toque o ponto de intersecção, o t, a normal, a orientação da face, e o material da esfera
        #A normal foi feito um calculo para verificar se ela esta apontando para fora ou para dentro
        toque.material = esfera.material
        toque.ponto_interseccao = pontoDoRaio(raio, raiz)
        toque.t = raiz;
        normal_para_fora = (toque.ponto_interseccao - esfera.centro)/esfera.raio
        toque.orientacaoDaFace = produtoEscalar(raio.direcao, normal_para_fora) < 0
        toque.normal = toque.orientacaoDaFace ? normal_para_fora : -normal_para_fora
        return true
    end
end

#Essa função calcula o ponto que intersectou a esfera
function pontoDoRaio(raio::Raio, t)
    return raio.origem + t * raio.direcao
end

#=
Essa função verifica se um raio atingiu algum objeto da cena,
modificando o parametro toque com as informações do toque caso tenha ocorrido
Retorna verdadeiro se atingiu algum objeto, e falso se não tocou;
=#
function tocou!(listaObjetosCena:: ListaObjetosDaCena, raio::Raio, toque::Toque, t_min, t_max)
    bateuEmAlgumObjeto = false
    auxToque = Toque()
    limite_maximo = t_max
    
    #Percorre os objetos da cena, verificando se bate em algum
    for objeto in listaObjetosCena.objetos
        if(tocou!(objeto, raio, auxToque, t_min, limite_maximo))
            limite_maximo = auxToque.t
            bateuEmAlgumObjeto = true
            toque.ponto_interseccao = auxToque.ponto_interseccao
            toque.normal = auxToque.normal
            toque.t = auxToque.t
            toque.orientacaoDaFace = auxToque.orientacaoDaFace
            toque.material = auxToque.material
        end
    end
    
    return bateuEmAlgumObjeto
end

#Essa função calcula a direção de reflexão de um raio
function refletir(direcao::Vec3, normal::Vec3)
    return direcao -2.0 * produtoEscalar(direcao, normal) * normal
end

#Definindo a operação * no tipo RGB
function *(cor1::RGB, cor2::RGB)
    return RGB(cor1.r * cor2.r, cor1.g * cor2.g, cor1.b * cor2.b)
end

#Função de espalhamento do material metal
function espalhamento(material::Metal, raio::Raio, toque::Toque)
    #Direção do novo raio
    novaDirecao = refletir(raio.direcao, toque.normal) + material.fuzzy * vetorNaEsfera();
    if(produtoEscalar(novaDirecao, toque.normal) > 0)
        return material.cor, true, novaDirecao
    else 
        return material.cor, false, novaDirecao
    end
end

#Função que cria um vetor unitário aleatório
function vetorUnitarioAleatorio()
    θ = rand(0.0:0.001:2*π)
    α = rand(0.0:0.001:π)
    return Vec3(cos(θ) * sin(α), sin(θ) * sin(α), cos(α))
end

#Essa função cria um vetor aleatório na esfera
function vetorNaEsfera()
    θ = rand(0.0:0.001:2*π)
    α = rand(0.0:0.001:π)
    raio = rand()
    #Paramétrica da esfera
    return raio * Vec3(cos(θ) * sin(α), sin(θ) * sin(α), cos(α))
end

#Função de espalhamento do Lambertiano
function espalhamento(material::Lambertiano, raio::Raio, toque::Toque)
    #Direção do novo raio
    novaDirecao = toque.normal + vetorUnitarioAleatorio()
    if (all(map(valor->isapprox(valor, 0; atol=1e-8), novaDirecao)))
        novaDirecao = toque.normal
    end
    return material.cor, true, novaDirecao
end

#Calcula a direção da refração de um raio que passa pelo material dielétrico
function refracao(direcao::Vec3, normal::Vec3, razaoRefracao)
    cossenoθ = produtoEscalar(-direcao, normal)
    perpendicular = razaoRefracao * (direcao  + cossenoθ * normal)
    paralelo = -sqrt(1-normaSemRaiz(perpendicular)) * normal
    return perpendicular + paralelo
end

#Calcula a quantidade de luz que vai ser refletida e não refratada quando um raio atinge a superficie do material dieletrico
function refletancia(cosseno, indiceDeRefracao)
    aux = (1-indiceDeRefracao)/(1+indiceDeRefracao)
    aux = aux*aux
    return aux + (1-aux) * ((1-cosseno)^5)
end

#Função de espalhamento do Dieletrico
function espalhamento(material::Dieletrico, raio::Raio, toque::Toque)
    #Direção do novo raio
    razaoDeRefracao = toque.orientacaoDaFace ? 1.0/material.indiceDeRefracao : material.indiceDeRefracao
    cossenoθ = produtoEscalar(-raio.direcao, toque.normal)
    senoθ = sqrt(1-cossenoθ^2)
    naoPodeRefratar = razaoDeRefracao * senoθ > 1.0
    novaDirecao=nothing
    if(naoPodeRefratar || refletancia(cossenoθ, razaoDeRefracao) > rand())
        novaDirecao = refletir(raio.direcao, toque.normal)
    else
        novaDirecao = refracao(raio.direcao, toque.normal, razaoDeRefracao)
    end
    return RGB(1.0, 1.0, 1.0), true, novaDirecao
end

#Essa função irá criar um raio a para um ponto na janela, a partir da camera, atribuindo sua direção e sua origem
function criaRaio(camera, u, v)
    #Calcula a direção
    direcao = camera.cantoInferiorEsquerdo + u*camera.horizontal + v*camera.vertical - camera.deOndeEstaOlhando;
    return Raio(camera.deOndeEstaOlhando, direcao)
end


#Essa função garante que uma cor estará no intervalo correto
function garanteIntervaloCor(cor:: RGB)
    r = min(max(cor.r, 0), 1)
    g = min(max(cor.g, 0), 1)
    b = min(max(cor.b, 0), 1)
    return RGB(r,g,b)
end

#Essa função aplica a correção GAMA encima de uma cor passada como parâmetro
function correcaoGama(cor::RGB)
    corNova = sqrt.([cor.r, cor.g, cor.b])
    return RGB(corNova[1], corNova[2], corNova[3])
end

#Essa função calcula a cor do fundo da imagem, a partir da direção do raio
function corDeFundo(direcao)
    aux = 0.5 * (direcao[2] + 1.0)
    return (1-aux)RGB(1.0, 1.0, 1.0) + aux*RGB(0.3, 0.5, 1.0)
end

#Essa função retorna a cor de um raio
function corDoRaio(raio::Raio, listaObjetosCena::ListaObjetosDaCena, qtdd_max_raios_refletidos_cena::Int)
    toque = Toque()

    if (qtdd_max_raios_refletidos_cena <= 0)
        return RGB(0.0, 0.0, 0.0)
    end

    if tocou!(listaObjetosCena, raio, toque, 0.0001, Inf)
        cor, lancaRaio, direcao = espalhamento(toque.material, raio, toque);
        if lancaRaio
            novoRaio = Raio(toque.ponto_interseccao, direcao)
            return cor * corDoRaio(novoRaio, listaObjetosCena, qtdd_max_raios_refletidos_cena-1)
        else
            return RGB(0.0, 0.0, 0.0)
        end
    end
    return corDeFundo(raio.direcao)
end

#Struct para representar a câmera
struct Camera
    #Atributos da câmera
    #De onde esta olhando
    deOndeEstaOlhando::Vec3
    #Vetor vertical da janela
    vertical:: Vec3
    #Vetor horizontal da janela
    horizontal:: Vec3
    #Posição do Canto inferior esquerdo
    cantoInferiorEsquerdo::Vec3

    #=
    Construtor da struct, recebe o angulo de visão vertical (fovVertical),
    a direção para cima relativa a câmera,
    de onde ela esta olhando,
    e para onde ela esta olhando.
    =#
    function Camera(fovVertical, direcaoParaCima::Vec3, deOndeEstaOlhando::Vec3, paraOndeEstaOlhando::Vec3)
        #Diferença de onde eu estou e onde eu estou olhando
        w = vetorUnitario(deOndeEstaOlhando - paraOndeEstaOlhando)
        #Direção horizontal
        direcaoHorizontal = vetorUnitario(produtoVetorial(direcaoParaCima, w))
        #Direção vertical
        direcaoVertical = produtoVetorial(w, direcaoHorizontal)
        
        #Calculando a altura  e a largura da janela
        θ = deg2rad(fovVertical)
        alturaJanela = 2.0 * (tan(θ/2))
        larguraJanela = alturaJanela * razaoDeAspecto;

        #Vetor horizontal da janela
        horizontal = direcaoHorizontal * larguraJanela;
        #Vetor vertical da janela
        vertical = direcaoVertical * alturaJanela;
        #Posição do canto inferior esquerdo da janela
        cantoInferiorEsquerdo = deOndeEstaOlhando - horizontal/2 - vertical/2 - w

        new(deOndeEstaOlhando, vertical, horizontal, cantoInferiorEsquerdo)
    end
end