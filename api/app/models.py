# aca deben ir las clases que representaran cada una de las tablas

#examples
from typing import Any
from sqlmodel import Field, SQLModel
from datetime import datetime
from typing import Optional
from geoalchemy2.types import Geometry

class Ciclovias(SQLModel, table=True):
    #Variables de identificación
    id: Optional[int] = Field(default=None,primary_key=True)
    comuna: str
    n_ciclo: int #Preguntar
    id_2: int #Preguntar
    date_mtt: int
    date_masciclo: int
    name_ciclo: str
    #Categorías fundamentales
    ciclo_o_cruce: int
    oneway: int
    phanto:int
    len_ciclo: float
    #Variables de entorno
    tipo_via_ciclo: int
    ancho_calle: float
    pista_calle: int
    tipo_via_cruce: int
    #Variables tipológicas
    ciclo_calle: int
    ciclo_vereda: int
    ciclo_plata_banda: int
    ciclo_bandejon: int
    ciclo_parque: int
    otro_ciclo: int
    tipo_ciclo: str
    #Variables de calidad ciclovias
    material: str
    ancho_via: float
    ancho_segregacion: float
    tipo_segregacion_vereda: int
    tipo_segregacion_calle: int
    color_pavimento: int
    lineas_pavimento: int
    #Variables de calidad cruces
    senalizado: int
    pintado: int
    semaforo: int
    cartel: int
    aproximacion_cruce: int
    otro_cruce: int
    #Variables de proyecto
    proyectado: int #Preguntar
    id_proyecto: int
    #Variable de calidad
    operatividad_ciclo: int
    operatividad_superficie: int
    operatividad_segregacion_calle: int
    operatividad_segregacion_vereda: int
    operatividad_demarcacion: int
    operatividad_cruce: int
    geometry: Optional[Any] = Field(sa_column=Column(Geometry('GEOMETRY')))

class OSM(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    type: str
    oneway_osm: int
    geometry: Optional[Any] = Field(sa_column=Column(Geometry('GEOMETRY')))

class H3(SQLModel, table=True):
    #Variables de entrada
    id: Optional[int] = Field(default=None, primary_key=True) #Preguntar
    manz_nse_u: int
    comuna: str
    abc1: float
    c2: float
    c3: float
    d: float
    e: float
    habitantes: float
    com_p: float
    of_p: float
    dep_c: float
    of_c: float
    metro: float
    malls: float
    fid_hex_10: float
    shape_leng: float
    shape_area: float
    #Variables post proceso
    largo_ciclovia: float
    largo_phanto: float
    largo_project1: float
    largo_project2: float
    largo_ciclovias_buenas: float
    largo_ciclovas_malas: float
    numero_cruces_buenos: int
    numero_cruces_malos: int
    largo_total_ciclovias_buenas: float
    largo_total_ciclovias_malas: float
    largo_osm: float
    largo_componente_intersectado: float
    largo_total_componente: float
    componente_ciclable: float
    geometry: Optional[Any] = Field(sa_column=Column(Geometry('GEOMETRY')))

class Inhibidores(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    geometry: Optional[Any] = Field(sa_column=Column(Geometry('GEOMETRY')))

    
class Desinhibidores(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    geometry: Optional[Any] = Field(sa_column=Column(Geometry('GEOMETRY')))

class Red(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    geometry: Optional[Any] = Field(sa_column=Column(Geometry('GEOMETRY')))