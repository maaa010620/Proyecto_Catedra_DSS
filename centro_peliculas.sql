-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 04-03-2021 a las 04:08:16
-- Versión del servidor: 5.7.31
-- Versión de PHP: 7.3.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `centro_peliculas`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alquileres`
--

DROP TABLE IF EXISTS `alquileres`;
CREATE TABLE IF NOT EXISTS `alquileres` (
  `codPelicula` int(11) NOT NULL,
  `codUsuario` int(11) NOT NULL,
  `precioAlquiler` decimal(10,2) DEFAULT NULL,
  `fechaInicio` date NOT NULL,
  `fechaFin` date NOT NULL,
  `fechaRetorno` date DEFAULT NULL,
  `multa` decimal(10,2) DEFAULT '0.00',
  `unidades` int(11) NOT NULL,
  KEY `codPelicula` (`codPelicula`),
  KEY `codUsuario` (`codUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `alquileres`
--

INSERT INTO `alquileres` (`codPelicula`, `codUsuario`, `precioAlquiler`, `fechaInicio`, `fechaFin`, `fechaRetorno`, `multa`, `unidades`) VALUES
(202101, 20001, '1.99', '2021-02-07', '2021-02-14', '2021-02-18', '2.00', 1),
(202101, 20002, '1.99', '2021-02-21', '2021-02-28', '2021-02-28', '0.00', 1),
(202104, 20004, '1.99', '2021-01-07', '2021-01-14', '2021-01-18', '2.00', 1),
(202105, 20005, '1.99', '2021-02-10', '2021-02-20', '2021-02-20', '0.00', 1),
(202106, 20006, '2.00', '2021-01-15', '2021-01-25', '2020-01-25', '0.00', 5),
(202106, 20007, '2.00', '2021-02-28', '2021-03-07', NULL, '0.00', 1),
(202107, 20008, '2.00', '2021-02-25', '2021-03-04', NULL, '0.00', 1),
(202104, 20004, '1.99', '2021-02-01', '2021-02-08', NULL, '0.00', 1);

--
-- Disparadores `alquileres`
--
DROP TRIGGER IF EXISTS `agregar_precio_actual_alquiler`;
DELIMITER $$
CREATE TRIGGER `agregar_precio_actual_alquiler` BEFORE INSERT ON `alquileres` FOR EACH ROW SET new.precioAlquiler = (SELECT precioAlquiler FROM peliculas WHERE codPelicula= new.codPelicula)
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `check_fechafin_mayor_fechainicio`;
DELIMITER $$
CREATE TRIGGER `check_fechafin_mayor_fechainicio` BEFORE INSERT ON `alquileres` FOR EACH ROW IF new.fechaFin < new.fechaInicio THEN SIGNAL SQLSTATE '12345'
    SET MESSAGE_TEXT
        = "Rango de fechas no es valido" ;
    END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `check_positivos_alquileres`;
DELIMITER $$
CREATE TRIGGER `check_positivos_alquileres` BEFORE INSERT ON `alquileres` FOR EACH ROW IF new.unidades<0 THEN SIGNAL SQLSTATE '12345'
    SET MESSAGE_TEXT
        = "Valores negativos no son admitidos" ;
    END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `regreso_pelicula`;
DELIMITER $$
CREATE TRIGGER `regreso_pelicula` BEFORE UPDATE ON `alquileres` FOR EACH ROW IF new.fechaRetorno > old.fechaFin THEN
SET new.multa = old.unidades*0.50*DATEDIFF( new.fechaRetorno,old.fechaFin);
UPDATE peliculas SET disponibilidad = disponibilidad+old.unidades WHERE codPelicula = new.codPelicula;
ELSE
UPDATE peliculas SET disponibilidad = disponibilidad+old.unidades WHERE codPelicula = new.codPelicula;
END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `verificar_disponibilidad_alquiler`;
DELIMITER $$
CREATE TRIGGER `verificar_disponibilidad_alquiler` BEFORE INSERT ON `alquileres` FOR EACH ROW IF new.unidades>(SELECT disponibilidad FROM peliculas WHERE codPelicula = new.codPelicula)
THEN SIGNAL SQLSTATE '12345'
    SET MESSAGE_TEXT
        = "NO EXISTE DISPONIBILIDAD";
ELSE
UPDATE peliculas SET disponibilidad = disponibilidad-new.unidades WHERE codPelicula = new.codPelicula;
END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `cambios_precio_alquiler`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `cambios_precio_alquiler`;
CREATE TABLE IF NOT EXISTS `cambios_precio_alquiler` (
`título` varchar(80)
,`Precio Alquiler Viejo` decimal(10,2)
,`Precio Alquiler Nuevo` decimal(10,2)
,`Fecha y Hora de Actualización` datetime
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `cambios_precio_compra`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `cambios_precio_compra`;
CREATE TABLE IF NOT EXISTS `cambios_precio_compra` (
`título` varchar(80)
,`Precio Compra Viejo` decimal(10,2)
,`Precio Compra Nuevo` decimal(10,2)
,`Fecha y Hora de Actualización` datetime
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compras`
--

DROP TABLE IF EXISTS `compras`;
CREATE TABLE IF NOT EXISTS `compras` (
  `codPelicula` int(11) NOT NULL,
  `codUsuario` int(11) NOT NULL,
  `precioCompra` decimal(10,2) DEFAULT NULL,
  `fechaCompra` date NOT NULL,
  `unidades` int(11) NOT NULL,
  KEY `codPelicula` (`codPelicula`),
  KEY `codUsuario` (`codUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `compras`
--

INSERT INTO `compras` (`codPelicula`, `codUsuario`, `precioCompra`, `fechaCompra`, `unidades`) VALUES
(202101, 20001, '5.99', '2021-02-12', 1),
(202104, 20004, '4.99', '2020-04-15', 1),
(202105, 20005, '4.99', '2021-03-01', 2),
(202106, 20006, '10.99', '2021-01-17', 3),
(202107, 20007, '5.99', '2020-05-13', 5),
(202108, 20001, '9.99', '2021-03-03', 2);

--
-- Disparadores `compras`
--
DROP TRIGGER IF EXISTS `agregar_precio_actual_compra`;
DELIMITER $$
CREATE TRIGGER `agregar_precio_actual_compra` BEFORE INSERT ON `compras` FOR EACH ROW SET new.precioCompra = (SELECT precioCompra FROM peliculas WHERE codPelicula= new.codPelicula)
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `check_positivos_compras`;
DELIMITER $$
CREATE TRIGGER `check_positivos_compras` BEFORE INSERT ON `compras` FOR EACH ROW IF new.unidades<0 THEN SIGNAL SQLSTATE '12345' SET MESSAGE_TEXT = "Valores negativos no son admitidos"; END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `verificar_disponibilidad_compra`;
DELIMITER $$
CREATE TRIGGER `verificar_disponibilidad_compra` BEFORE INSERT ON `compras` FOR EACH ROW IF new.unidades>(SELECT disponibilidad FROM peliculas WHERE codPelicula = new.codPelicula)
THEN SIGNAL SQLSTATE '12345'
    SET MESSAGE_TEXT
        = "NO EXISTE DISPONIBILIDAD";
ELSE
UPDATE peliculas SET stock = stock-new.unidades, disponibilidad = disponibilidad-new.unidades WHERE codPelicula = new.codPelicula;
END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_precios_alquiler`
--

DROP TABLE IF EXISTS `log_precios_alquiler`;
CREATE TABLE IF NOT EXISTS `log_precios_alquiler` (
  `codPelicula` int(11) NOT NULL,
  `precioAlquilerViejo` decimal(10,2) NOT NULL,
  `precioAlquilerNuevo` decimal(10,2) NOT NULL,
  `fechaCambio` datetime NOT NULL,
  KEY `codPelicula` (`codPelicula`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `log_precios_alquiler`
--

INSERT INTO `log_precios_alquiler` (`codPelicula`, `precioAlquilerViejo`, `precioAlquilerNuevo`, `fechaCambio`) VALUES
(202101, '2.99', '2.99', '2021-03-02 06:14:10'),
(202101, '2.99', '1.99', '2021-03-02 06:19:48'),
(202104, '1.99', '1.99', '2021-03-03 00:54:38'),
(202105, '1.99', '1.99', '2021-03-03 01:01:47'),
(202106, '2.00', '2.00', '2021-03-03 01:07:26'),
(202107, '2.00', '2.00', '2021-03-03 17:02:17'),
(202108, '3.99', '3.99', '2021-03-03 20:58:14'),
(202106, '2.00', '2.99', '2021-03-03 21:05:54'),
(200201, '2.99', '2.99', '2021-03-03 22:03:30'),
(200701, '2.99', '2.99', '2021-03-03 22:03:30'),
(201301, '3.99', '3.99', '2021-03-03 22:03:30'),
(201801, '3.99', '3.99', '2021-03-03 22:03:30'),
(201901, '3.99', '3.99', '2021-03-03 22:03:30'),
(202102, '2.99', '2.99', '2021-03-03 22:03:30');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_precios_compra`
--

DROP TABLE IF EXISTS `log_precios_compra`;
CREATE TABLE IF NOT EXISTS `log_precios_compra` (
  `codPelicula` int(11) NOT NULL,
  `precioCompraViejo` decimal(10,2) NOT NULL,
  `precioCompraNuevo` decimal(10,2) NOT NULL,
  `fechaCambio` datetime NOT NULL,
  KEY `codPelicula` (`codPelicula`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `log_precios_compra`
--

INSERT INTO `log_precios_compra` (`codPelicula`, `precioCompraViejo`, `precioCompraNuevo`, `fechaCambio`) VALUES
(202101, '8.99', '8.99', '2021-03-02 06:14:10'),
(202101, '8.99', '5.99', '2021-03-02 06:20:33'),
(202104, '4.99', '4.99', '2021-03-03 00:54:38'),
(202105, '4.99', '4.99', '2021-03-03 01:01:47'),
(202106, '10.99', '10.99', '2021-03-03 01:07:26'),
(202107, '5.99', '5.99', '2021-03-03 17:02:17'),
(202108, '9.99', '9.99', '2021-03-03 20:58:14'),
(202106, '10.99', '9.99', '2021-03-03 21:05:54'),
(200201, '5.50', '5.50', '2021-03-03 22:03:30'),
(200701, '7.50', '7.50', '2021-03-03 22:03:30'),
(201301, '6.50', '6.50', '2021-03-03 22:03:30'),
(201801, '10.00', '10.00', '2021-03-03 22:03:30'),
(201901, '10.00', '10.00', '2021-03-03 22:03:30'),
(202102, '8.50', '8.50', '2021-03-03 22:03:30');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `peliculas`
--

DROP TABLE IF EXISTS `peliculas`;
CREATE TABLE IF NOT EXISTS `peliculas` (
  `codPelicula` int(11) NOT NULL AUTO_INCREMENT,
  `título` varchar(80) NOT NULL,
  `descripción` text NOT NULL,
  `imagenURL` varchar(80) NOT NULL,
  `precioAlquiler` decimal(10,2) NOT NULL,
  `precioCompra` decimal(10,2) NOT NULL,
  `stock` int(11) NOT NULL,
  `disponibilidad` int(11) NOT NULL,
  `likes` int(11) NOT NULL,
  PRIMARY KEY (`codPelicula`)
) ENGINE=InnoDB AUTO_INCREMENT=202109 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `peliculas`
--

INSERT INTO `peliculas` (`codPelicula`, `título`, `descripción`, `imagenURL`, `precioAlquiler`, `precioCompra`, `stock`, `disponibilidad`, `likes`) VALUES
(200201, 'Resident Evil', 'En un centro clandestino de investigación genética, se produce un virus mortal. Para contener la fuga, se cierra toda la instalación y se cree que mueren todos los empleados, pero en realidad se convierten en zombis.', 'caratula.img', '2.99', '5.50', 4, 0, 100),
(200701, 'Soy leyenda', 'Robert Neville, un brillante científico, es el único sobreviviente de una plaga creada por el hombre que transforma a los humanos en mutantes sedientos de sangre. Él vaga solitario por Nueva York, buscando a posibles sobrevivientes, y trabaja para hallar una cura para la plaga usando su propia sangre inmune. Neville sabe que las posibilidades son mínimas, y todos esperan que cometa un error para que él caiga en sus manos.', 'caratula.jpg', '2.99', '7.50', 2, 5, 230),
(201301, 'El expreso del miedo', 'El calentamiento global ha aniquilado a casi toda la humanidad. Los supervivientes viajan en un tren que atraviesa un mundo de hielo y nieve, un tren en el que hay dos clases sociales claramente diferenciadas, pero el descontento lleva a la revuelta.', 'caratula.jpg', '3.99', '6.50', 3, 4, 300),
(201801, 'Spider-Man: un nuevo universo', 'Luego de ser mordido por una araña radioactiva, el joven Miles Morales desarrolla misteriosos poderes que lo transforman en el Hombre Araña. Ahora deberá usar sus nuevas habilidades ante el malvado Kingpin, un enorme demente que puede abrir portales hacia otros universos.', 'caratula.jpg', '3.99', '10.00', 6, 6, 300),
(201901, 'Avengers: Endgame', 'Los Vengadores restantes deben encontrar una manera de recuperar a sus aliados para un enfrentamiento épico con Thanos, el malvado que diezmó el planeta y el universo.', 'caratula.jpg', '3.99', '10.00', 6, 7, 500),
(202101, 'Titanic', 'Titanic es una película estadounidense dramática de catástrofe de 1997 dirigida y escrita por James Cameron y protagonizada por Leonardo DiCaprio, Kate Winslet, Billy Zane, Kathy Bates, Gloria Stuart y Bill Paxton. La trama, una epopeya romántica, relata la relación de Jack Dawson y Rose DeWitt Bukater, dos jóvenes que se conocen y se enamoran a bordo del transatlántico RMS Titanic en su viaje inaugural desde Southampton, Inglaterra, a Nueva York, EE. UU., en abril de 1912. Pertenecientes a diferentes clases sociales, intentan salir adelante pese a las adversidades que los separarían de forma definitiva, entre ellas el prometido de Rose, Caledon «Cal» Hockley (un adinerado del cual ella no está enamorada, pero su madre la ha obligado a permanecer con él para garantizar un futuro económico próspero)', 'test.img', '1.99', '5.99', 5, 5, 450),
(202102, 'Black Widow', 'Al nacer, la Viuda Negra, también conocida como Natasha Romanova, se entrega a la KGB para convertirse en su agente definitivo. Cuando la URSS se separa, el gobierno intenta matarla mientras la acción se traslada a la actual Nueva York.', 'caratula.jpg', '2.99', '8.50', 4, 5, 230),
(202104, 'John Wick', 'John Wick ,un asesino a sueldo ,se enfrenta al mafioso Viggo Tarazov,quien ofrece una recompensa a quel que logre acabar con la vida Wick', 'test.img ', '1.99', '4.99', 4, 3, 500),
(202105, 'Nemo', 'Marlin, un pez payaso,simore ha intentado proteger de todos los peligros a su hijo .Sin embargi,un buzu atrapa al pequeño, y ahora el padre debera embarcarse en una increible aventura por las australianas para encontrarlo.', 'test.img', '1.99', '4.99', 6, 6, 600),
(202106, 'IT', 'Varios niños de una pequeña cuidad del estado de Maine se alian para combatir a una entidad diabilica que adopta la forma de payaso y dese hace mucho tiempo emerge cada 27 años para saciarse de sangre infantil.', 'test.img ', '2.99', '9.99', 7, 6, 1000),
(202107, 'Son Como niños', 'Un grupo de amigos y excomapañeros descubren que envejecer no simpre significa madurar cuando se reunen para honrar la memoria de su entrenador de baloncesto', 'test.img', '2.00', '5.99', 10, 9, 1000),
(202108, 'It Capítulo Dos', 'En 1989, en Derry, Maine, después de haber derrotado a «Eso», Beverly Marsh (Sophia Lillis) les revela a sus amigos del «Club de los Perdedores» que cuando Pennywise, el payaso bailarín (Bill Skarsgård) la secuestró y la dejó en trance, ella vio a todos en sus versiones adultas, entonces Bill Denbrough (Jaeden Martell) pacta un juramento de sangre con sus amigos en el que prometen que si Pennywise algún día regresa, ellos también lo harán para detenerlo y acabar con él para siempre.', 'caratula.img', '3.99', '9.99', 6, 6, 560);

--
-- Disparadores `peliculas`
--
DROP TRIGGER IF EXISTS `cambio_precio_alquiler`;
DELIMITER $$
CREATE TRIGGER `cambio_precio_alquiler` AFTER UPDATE ON `peliculas` FOR EACH ROW IF old.precioAlquiler <> new.precioAlquiler THEN
INSERT INTO log_precios_alquiler (codPelicula, precioAlquilerViejo, precioAlquilerNuevo, fechaCambio)
VALUES (new.codPelicula, old.precioAlquiler, new.precioAlquiler,NOW());
END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `cambio_precio_compra`;
DELIMITER $$
CREATE TRIGGER `cambio_precio_compra` AFTER UPDATE ON `peliculas` FOR EACH ROW IF old.precioCompra <> new.precioCompra THEN
INSERT INTO log_precios_compra (codPelicula, precioCompraViejo, precioCompraNuevo, fechaCambio)
VALUES (new.codPelicula, old.precioCompra, new.precioCompra,NOW());
END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `check_positivos_peliculas`;
DELIMITER $$
CREATE TRIGGER `check_positivos_peliculas` BEFORE INSERT ON `peliculas` FOR EACH ROW IF new.precioAlquiler<0 OR new.precioCompra<0 OR new.stock<0 OR new.likes<0 OR new.disponibilidad<0 
THEN SIGNAL SQLSTATE '12345'
    SET MESSAGE_TEXT
        = "Valores negativos no son admitidos" ;
    END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `registrar_precio_original_alquiler`;
DELIMITER $$
CREATE TRIGGER `registrar_precio_original_alquiler` AFTER INSERT ON `peliculas` FOR EACH ROW INSERT INTO log_precios_alquiler (codPelicula, precioAlquilerViejo, precioAlquilerNuevo, fechaCambio)
VALUES (new.codPelicula, new.precioAlquiler, new.precioAlquiler, NOW())
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `registrar_precio_original_compra`;
DELIMITER $$
CREATE TRIGGER `registrar_precio_original_compra` AFTER INSERT ON `peliculas` FOR EACH ROW INSERT INTO log_precios_compra (codPelicula, precioCompraViejo, precioCompraNuevo, fechaCambio)
VALUES (new.codPelicula, new.precioCompra, new.precioCompra,NOW())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `peliculas_alquiladas_actualmente`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `peliculas_alquiladas_actualmente`;
CREATE TABLE IF NOT EXISTS `peliculas_alquiladas_actualmente` (
`Título` varchar(80)
,`Nombre` varchar(80)
,`Apellidos` varchar(80)
,`Fecha Inicio` date
,`Fecha Fin` date
,`Unidades` int(11)
,`Precio` decimal(10,2)
,`Total` decimal(20,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `peliculas_alquiladas_previamente`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `peliculas_alquiladas_previamente`;
CREATE TABLE IF NOT EXISTS `peliculas_alquiladas_previamente` (
`Título` varchar(80)
,`Nombre` varchar(80)
,`Apellidos` varchar(80)
,`Fecha Inicio` date
,`Fecha Fin` date
,`Fecha Retorno` date
,`Unidades` int(11)
,`Precio` decimal(10,2)
,`Multa` decimal(10,2)
,`Total` decimal(21,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `peliculas_disponibles`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `peliculas_disponibles`;
CREATE TABLE IF NOT EXISTS `peliculas_disponibles` (
`Código` int(11)
,`Título` varchar(80)
,`Descripción` text
,`Carátula` varchar(80)
,`Precio Alquiler` decimal(10,2)
,`PrecioCompra` decimal(10,2)
,`Unidades Totales` int(11)
,`Unidades Disponibles` int(11)
,`Likes` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `peliculas_no_disponibles`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `peliculas_no_disponibles`;
CREATE TABLE IF NOT EXISTS `peliculas_no_disponibles` (
`Código` int(11)
,`Título` varchar(80)
,`Descripción` text
,`Carátula` varchar(80)
,`Precio Alquiler` decimal(10,2)
,`PrecioCompra` decimal(10,2)
,`Unidades Totales` int(11)
,`Unidades Disponibles` int(11)
,`Likes` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `peliculas_retornadas_puntualmente`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `peliculas_retornadas_puntualmente`;
CREATE TABLE IF NOT EXISTS `peliculas_retornadas_puntualmente` (
`Título` varchar(80)
,`Nombre` varchar(80)
,`Apellidos` varchar(80)
,`Fecha Inicio` date
,`Fecha Fin` date
,`Fecha Retorno` date
,`Unidades` int(11)
,`Precio` decimal(10,2)
,`Multa` decimal(10,2)
,`Total` decimal(21,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `peliculas_retornadas_tarde`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `peliculas_retornadas_tarde`;
CREATE TABLE IF NOT EXISTS `peliculas_retornadas_tarde` (
`Título` varchar(80)
,`Nombre` varchar(80)
,`Apellidos` varchar(80)
,`Fecha Inicio` date
,`Fecha Fin` date
,`Fecha Retorno` date
,`Unidades` int(11)
,`Precio` decimal(10,2)
,`Multa` decimal(10,2)
,`Total` decimal(21,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `peliculas_todas`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `peliculas_todas`;
CREATE TABLE IF NOT EXISTS `peliculas_todas` (
`Código` int(11)
,`Título` varchar(80)
,`Descripción` text
,`Carátula` varchar(80)
,`Precio Alquiler` decimal(10,2)
,`PrecioCompra` decimal(10,2)
,`Unidades Totales` int(11)
,`Unidades Disponibles` int(11)
,`Likes` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `peliculas_vendidas`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `peliculas_vendidas`;
CREATE TABLE IF NOT EXISTS `peliculas_vendidas` (
`Título` varchar(80)
,`Nombre` varchar(80)
,`Apellidos` varchar(80)
,`Fecha` date
,`Unidades` int(11)
,`Precio` decimal(10,2)
,`Total` decimal(20,2)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE IF NOT EXISTS `usuarios` (
  `codUsuario` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) NOT NULL,
  `apellido` varchar(80) NOT NULL,
  `fechaNac` date NOT NULL,
  `dirección` varchar(120) NOT NULL,
  `teléfono` varchar(20) NOT NULL,
  `adminStatus` tinyint(1) NOT NULL,
  PRIMARY KEY (`codUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=20014 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`codUsuario`, `nombre`, `apellido`, `fechaNac`, `dirección`, `teléfono`, `adminStatus`) VALUES
(20001, 'Anthony', 'Pérez', '1996-06-29', 'Cl 25 De Abril Ote Y Av San José, San Salvador, San Salvador', '70548934', 1),
(20002, 'José', 'Lopez', '2001-04-10', 'Resid Sta Teresa Av Sta Teresa Sda 2 Políg C-3 No 7, Santa Tecla, San Salvador', '22297306', 1),
(20003, 'Marco', 'Arias', '2021-03-01', 'el salvador, san salvador', '2222-3434', 1),
(20004, 'Isaac', 'Menlendez', '1977-12-30', 'BLV y cond los Heroes NVL3 loc 310,san salvador, el salvador', '22265552', 0),
(20005, 'Blanca', 'Rodriguez', '1984-12-03', ' Colonia Escalon,San Salvador,el salvador', '22790123', 1),
(20006, 'Damian', 'Vicente', '1982-05-10', ' Colonia Centro las Amaericas los pinares, San salvador, El salvador', '22350325', 0),
(20007, 'Juan', 'Hermoso', '2001-07-15', 'Blvd del ejercito Nac km 31/2,San salvador,El salvador', '22931444', 0),
(20008, 'Patricia', 'Portillo', '1982-06-25', 'Col Roma CI el progreso No 6, San salvador, El salvador', '70261802', 0),
(20009, 'Dennis', 'Monge', '1984-07-10', 'Colonia Escalon Avenida Sur y calle padre saguilar,San salvador, El salvador', '22110972', 0),
(20010, 'Yanira', 'Quiros', '1993-11-17', 'Col Miramonte No 14, San salvador, El salvador', '22985708', 1),
(20011, 'Oscar', 'Royo', '1999-06-20', 'Colonia Flor blanca 31 AV Sur No 633, San Salvador, El salvador', '79306772', 0),
(20012, 'Rafael', 'Sanmartin', '2000-03-02', 'Bo San Rafael 5 Cl Ote Y 13 Av Sur', '2447-1010', 1),
(20013, 'Ogima', 'Navajo', '2000-04-08', 'Calle Arce # 827, San Salvador', '2221-0966', 0);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `usuarios_administradores`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `usuarios_administradores`;
CREATE TABLE IF NOT EXISTS `usuarios_administradores` (
`Código` int(11)
,`Nombre` varchar(80)
,`Apellido` varchar(80)
,`Fecha de Nacimiento` date
,`Teléfono` varchar(20)
,`Dirección` varchar(120)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `usuarios_no_administradores`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `usuarios_no_administradores`;
CREATE TABLE IF NOT EXISTS `usuarios_no_administradores` (
`Código` int(11)
,`Nombre` varchar(80)
,`Apellido` varchar(80)
,`Fecha de Nacimiento` date
,`Teléfono` varchar(20)
,`Dirección` varchar(120)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `cambios_precio_alquiler`
--
DROP TABLE IF EXISTS `cambios_precio_alquiler`;

DROP VIEW IF EXISTS `cambios_precio_alquiler`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `cambios_precio_alquiler`  AS  select `peliculas`.`título` AS `título`,`log_precios_alquiler`.`precioAlquilerViejo` AS `Precio Alquiler Viejo`,`log_precios_alquiler`.`precioAlquilerNuevo` AS `Precio Alquiler Nuevo`,`log_precios_alquiler`.`fechaCambio` AS `Fecha y Hora de Actualización` from (`log_precios_alquiler` join `peliculas` on((`log_precios_alquiler`.`codPelicula` = `peliculas`.`codPelicula`))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `cambios_precio_compra`
--
DROP TABLE IF EXISTS `cambios_precio_compra`;

DROP VIEW IF EXISTS `cambios_precio_compra`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `cambios_precio_compra`  AS  select `peliculas`.`título` AS `título`,`log_precios_compra`.`precioCompraViejo` AS `Precio Compra Viejo`,`log_precios_compra`.`precioCompraNuevo` AS `Precio Compra Nuevo`,`log_precios_compra`.`fechaCambio` AS `Fecha y Hora de Actualización` from (`log_precios_compra` join `peliculas` on((`log_precios_compra`.`codPelicula` = `peliculas`.`codPelicula`))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `peliculas_alquiladas_actualmente`
--
DROP TABLE IF EXISTS `peliculas_alquiladas_actualmente`;

DROP VIEW IF EXISTS `peliculas_alquiladas_actualmente`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `peliculas_alquiladas_actualmente`  AS  select `peliculas`.`título` AS `Título`,`usuarios`.`nombre` AS `Nombre`,`usuarios`.`apellido` AS `Apellidos`,`alquileres`.`fechaInicio` AS `Fecha Inicio`,`alquileres`.`fechaFin` AS `Fecha Fin`,`alquileres`.`unidades` AS `Unidades`,`alquileres`.`precioAlquiler` AS `Precio`,(`alquileres`.`unidades` * `alquileres`.`precioAlquiler`) AS `Total` from ((`alquileres` join `usuarios` on((`alquileres`.`codUsuario` = `usuarios`.`codUsuario`))) join `peliculas` on((`alquileres`.`codPelicula` = `peliculas`.`codPelicula`))) where isnull(`alquileres`.`fechaRetorno`) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `peliculas_alquiladas_previamente`
--
DROP TABLE IF EXISTS `peliculas_alquiladas_previamente`;

DROP VIEW IF EXISTS `peliculas_alquiladas_previamente`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `peliculas_alquiladas_previamente`  AS  select `peliculas`.`título` AS `Título`,`usuarios`.`nombre` AS `Nombre`,`usuarios`.`apellido` AS `Apellidos`,`alquileres`.`fechaInicio` AS `Fecha Inicio`,`alquileres`.`fechaFin` AS `Fecha Fin`,`alquileres`.`fechaRetorno` AS `Fecha Retorno`,`alquileres`.`unidades` AS `Unidades`,`alquileres`.`precioAlquiler` AS `Precio`,`alquileres`.`multa` AS `Multa`,((`alquileres`.`unidades` * `alquileres`.`precioAlquiler`) + `alquileres`.`multa`) AS `Total` from ((`alquileres` join `usuarios` on((`alquileres`.`codUsuario` = `usuarios`.`codUsuario`))) join `peliculas` on((`alquileres`.`codPelicula` = `peliculas`.`codPelicula`))) where (`alquileres`.`fechaRetorno` is not null) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `peliculas_disponibles`
--
DROP TABLE IF EXISTS `peliculas_disponibles`;

DROP VIEW IF EXISTS `peliculas_disponibles`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `peliculas_disponibles`  AS  select `peliculas`.`codPelicula` AS `Código`,`peliculas`.`título` AS `Título`,`peliculas`.`descripción` AS `Descripción`,`peliculas`.`imagenURL` AS `Carátula`,`peliculas`.`precioAlquiler` AS `Precio Alquiler`,`peliculas`.`precioCompra` AS `PrecioCompra`,`peliculas`.`stock` AS `Unidades Totales`,`peliculas`.`disponibilidad` AS `Unidades Disponibles`,`peliculas`.`likes` AS `Likes` from `peliculas` where (`peliculas`.`disponibilidad` > 0) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `peliculas_no_disponibles`
--
DROP TABLE IF EXISTS `peliculas_no_disponibles`;

DROP VIEW IF EXISTS `peliculas_no_disponibles`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `peliculas_no_disponibles`  AS  select `peliculas`.`codPelicula` AS `Código`,`peliculas`.`título` AS `Título`,`peliculas`.`descripción` AS `Descripción`,`peliculas`.`imagenURL` AS `Carátula`,`peliculas`.`precioAlquiler` AS `Precio Alquiler`,`peliculas`.`precioCompra` AS `PrecioCompra`,`peliculas`.`stock` AS `Unidades Totales`,`peliculas`.`disponibilidad` AS `Unidades Disponibles`,`peliculas`.`likes` AS `Likes` from `peliculas` where (`peliculas`.`disponibilidad` = 0) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `peliculas_retornadas_puntualmente`
--
DROP TABLE IF EXISTS `peliculas_retornadas_puntualmente`;

DROP VIEW IF EXISTS `peliculas_retornadas_puntualmente`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `peliculas_retornadas_puntualmente`  AS  select `peliculas`.`título` AS `Título`,`usuarios`.`nombre` AS `Nombre`,`usuarios`.`apellido` AS `Apellidos`,`alquileres`.`fechaInicio` AS `Fecha Inicio`,`alquileres`.`fechaFin` AS `Fecha Fin`,`alquileres`.`fechaRetorno` AS `Fecha Retorno`,`alquileres`.`unidades` AS `Unidades`,`alquileres`.`precioAlquiler` AS `Precio`,`alquileres`.`multa` AS `Multa`,((`alquileres`.`unidades` * `alquileres`.`precioAlquiler`) + `alquileres`.`multa`) AS `Total` from ((`alquileres` join `usuarios` on((`alquileres`.`codUsuario` = `usuarios`.`codUsuario`))) join `peliculas` on((`alquileres`.`codPelicula` = `peliculas`.`codPelicula`))) where ((`alquileres`.`fechaRetorno` is not null) and (`alquileres`.`multa` = '0.00')) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `peliculas_retornadas_tarde`
--
DROP TABLE IF EXISTS `peliculas_retornadas_tarde`;

DROP VIEW IF EXISTS `peliculas_retornadas_tarde`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `peliculas_retornadas_tarde`  AS  select `peliculas`.`título` AS `Título`,`usuarios`.`nombre` AS `Nombre`,`usuarios`.`apellido` AS `Apellidos`,`alquileres`.`fechaInicio` AS `Fecha Inicio`,`alquileres`.`fechaFin` AS `Fecha Fin`,`alquileres`.`fechaRetorno` AS `Fecha Retorno`,`alquileres`.`unidades` AS `Unidades`,`alquileres`.`precioAlquiler` AS `Precio`,`alquileres`.`multa` AS `Multa`,((`alquileres`.`unidades` * `alquileres`.`precioAlquiler`) + `alquileres`.`multa`) AS `Total` from ((`alquileres` join `usuarios` on((`alquileres`.`codUsuario` = `usuarios`.`codUsuario`))) join `peliculas` on((`alquileres`.`codPelicula` = `peliculas`.`codPelicula`))) where ((`alquileres`.`fechaRetorno` is not null) and (`alquileres`.`multa` > 0)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `peliculas_todas`
--
DROP TABLE IF EXISTS `peliculas_todas`;

DROP VIEW IF EXISTS `peliculas_todas`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `peliculas_todas`  AS  select `peliculas`.`codPelicula` AS `Código`,`peliculas`.`título` AS `Título`,`peliculas`.`descripción` AS `Descripción`,`peliculas`.`imagenURL` AS `Carátula`,`peliculas`.`precioAlquiler` AS `Precio Alquiler`,`peliculas`.`precioCompra` AS `PrecioCompra`,`peliculas`.`stock` AS `Unidades Totales`,`peliculas`.`disponibilidad` AS `Unidades Disponibles`,`peliculas`.`likes` AS `Likes` from `peliculas` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `peliculas_vendidas`
--
DROP TABLE IF EXISTS `peliculas_vendidas`;

DROP VIEW IF EXISTS `peliculas_vendidas`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `peliculas_vendidas`  AS  select `peliculas`.`título` AS `Título`,`usuarios`.`nombre` AS `Nombre`,`usuarios`.`apellido` AS `Apellidos`,`compras`.`fechaCompra` AS `Fecha`,`compras`.`unidades` AS `Unidades`,`compras`.`precioCompra` AS `Precio`,(`compras`.`unidades` * `compras`.`precioCompra`) AS `Total` from ((`compras` join `usuarios` on((`compras`.`codUsuario` = `usuarios`.`codUsuario`))) join `peliculas` on((`compras`.`codPelicula` = `peliculas`.`codPelicula`))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `usuarios_administradores`
--
DROP TABLE IF EXISTS `usuarios_administradores`;

DROP VIEW IF EXISTS `usuarios_administradores`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `usuarios_administradores`  AS  select `usuarios`.`codUsuario` AS `Código`,`usuarios`.`nombre` AS `Nombre`,`usuarios`.`apellido` AS `Apellido`,`usuarios`.`fechaNac` AS `Fecha de Nacimiento`,`usuarios`.`teléfono` AS `Teléfono`,`usuarios`.`dirección` AS `Dirección` from `usuarios` where (`usuarios`.`adminStatus` = '1') ;

-- --------------------------------------------------------

--
-- Estructura para la vista `usuarios_no_administradores`
--
DROP TABLE IF EXISTS `usuarios_no_administradores`;

DROP VIEW IF EXISTS `usuarios_no_administradores`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `usuarios_no_administradores`  AS  select `usuarios`.`codUsuario` AS `Código`,`usuarios`.`nombre` AS `Nombre`,`usuarios`.`apellido` AS `Apellido`,`usuarios`.`fechaNac` AS `Fecha de Nacimiento`,`usuarios`.`teléfono` AS `Teléfono`,`usuarios`.`dirección` AS `Dirección` from `usuarios` where (`usuarios`.`adminStatus` = '0') ;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `alquileres`
--
ALTER TABLE `alquileres`
  ADD CONSTRAINT `alquileres_ibfk_1` FOREIGN KEY (`codPelicula`) REFERENCES `peliculas` (`codPelicula`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `alquileres_ibfk_2` FOREIGN KEY (`codUsuario`) REFERENCES `usuarios` (`codUsuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `compras`
--
ALTER TABLE `compras`
  ADD CONSTRAINT `compras_ibfk_1` FOREIGN KEY (`codPelicula`) REFERENCES `peliculas` (`codPelicula`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `compras_ibfk_2` FOREIGN KEY (`codUsuario`) REFERENCES `usuarios` (`codUsuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `log_precios_alquiler`
--
ALTER TABLE `log_precios_alquiler`
  ADD CONSTRAINT `log_precios_alquiler_ibfk_1` FOREIGN KEY (`codPelicula`) REFERENCES `peliculas` (`codPelicula`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `log_precios_compra`
--
ALTER TABLE `log_precios_compra`
  ADD CONSTRAINT `log_precios_compra_ibfk_1` FOREIGN KEY (`codPelicula`) REFERENCES `peliculas` (`codPelicula`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
