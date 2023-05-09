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
    district: str
    id_bike: int #Preguntar
    id_2: int #Preguntar
    date_mtt: int
    date_masciclo: int
    name_bike: str
    #Categorías fundamentales
    bike_or_crossing: int
    oneway: int
    gap:int
    len_ciclo: float
    #Variables de entorno
    road_type_bike: int
    road_width: float
    road_num_lane: int
    road_type_cross: int
    #Variables tipológicas
    type_road: int
    type_sidewalk: int
    type_verge: int
    type_median: int
    type_green_way: int
    type_other: int
    type_summary: str
    #Variables de calidad ciclovias
    bike_material: str
    bike_width_surface: float
    bike_width_segregation: float
    bike_width_segregation_sidewalk_type: int
    bike_width_segregation_road_type: int
    bike_paint_surface: int
    bike_paint_demarcation: int
    #Variables de calidad cruces
    cross_paint_demarcation: int
    cross_paint_surface: int
    cross_traffic_ligth: int
    cross_traffic_sign: int
    cross_aproximation: int
    cross_other: int
    #Variables de proyecto
    proyect_level: int #Preguntar
    proyect_id: int
    #Variable de calidad
    conflict_bike: int
    conflict_by_surface: int
    conflict_by_traffic_motorized: int
    conflict_by_traffic_pedestrian: int
    conflict_by_illegible: int
    conflict_cross: int
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