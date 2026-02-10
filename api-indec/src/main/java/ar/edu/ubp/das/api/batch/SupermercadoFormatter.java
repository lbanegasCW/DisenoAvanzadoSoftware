package ar.edu.ubp.das.api.batch;

import ar.edu.ubp.das.api.batch.beans.HorarioSucursalBean;
import ar.edu.ubp.das.api.batch.beans.TipoServicioSucursalBean;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SupermercadoFormatter {

    private static final Map<Integer, String> DIA_SEMANA = new HashMap<>();

    static {
        DIA_SEMANA.put(1, "Lunes");
        DIA_SEMANA.put(2, "Martes");
        DIA_SEMANA.put(3, "Miércoles");
        DIA_SEMANA.put(4, "Jueves");
        DIA_SEMANA.put(5, "Viernes");
        DIA_SEMANA.put(6, "Sábado");
        DIA_SEMANA.put(7, "Domingo");
    }

    public static String formatearHorarios(List<HorarioSucursalBean> horarios) {
        StringBuilder resultado = new StringBuilder();

        for (HorarioSucursalBean horario : horarios) {
            String dia = DIA_SEMANA.get(horario.getDiaSemana());
            if (dia != null) {
                resultado.append(dia)
                        .append(": ")
                        .append(horario.getHoraDesde())
                        .append(" - ")
                        .append(horario.getHoraHasta())
                        .append(" / ");
            }
        }

        if (resultado.length() > 0) {
            resultado.setLength(resultado.length() - 3);
        }

        return resultado.toString();
    }

    public static String formatearServicios(List<TipoServicioSucursalBean> servicios) {
        StringBuilder resultado = new StringBuilder();

        for (int i = 0; i < servicios.size(); i++) {
            String servicio = servicios.get(i).getNomTipoServicio();
            if (servicio != null) {
                resultado
                        .append(servicio)
                        .append(" / ");
            }
        }

        if (resultado.length() > 0) {
            resultado.setLength(resultado.length() - 3);
        }

        return resultado.toString();
    }

}
