package ar.edu.ubp.das.super3.config;

import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.ws.config.annotation.EnableWs;
import org.springframework.ws.config.annotation.WsConfigurerAdapter;
import org.springframework.ws.transport.http.MessageDispatcherServlet;
import org.springframework.ws.wsdl.wsdl11.DefaultWsdl11Definition;
import org.springframework.xml.xsd.SimpleXsdSchema;
import org.springframework.xml.xsd.XsdSchema;
import org.springframework.ws.soap.SoapVersion;
import org.springframework.ws.soap.saaj.SaajSoapMessageFactory;

@EnableWs
@Configuration
public class WebServiceConfig extends WsConfigurerAdapter {

    @Bean
    public ServletRegistrationBean<MessageDispatcherServlet> messageDispatcherServlet(
            ApplicationContext applicationContext) {
        MessageDispatcherServlet servlet = new MessageDispatcherServlet();
        servlet.setApplicationContext(applicationContext);
        servlet.setTransformWsdlLocations(true);
        return new ServletRegistrationBean<>(servlet, "/ws/*");
    }

    @Bean
    public SaajSoapMessageFactory messageFactory() {
        SaajSoapMessageFactory messageFactory = new SaajSoapMessageFactory();
        messageFactory.setSoapVersion(SoapVersion.SOAP_12);
        return messageFactory;
    }

    // ---------- Sucursales ----------
    @Bean(name = "sucursales")
    public DefaultWsdl11Definition sucursalesWsdl(XsdSchema sucursalesSchema) {
        DefaultWsdl11Definition wsdl11Definition = new DefaultWsdl11Definition();
        wsdl11Definition.setPortTypeName("SucursalesPort");
        wsdl11Definition.setLocationUri("/ws");
        wsdl11Definition.setTargetNamespace("http://services.super3.das.ubp.edu.ar/");
        wsdl11Definition.setSchema(sucursalesSchema);
        wsdl11Definition.setCreateSoap12Binding(true);
        return wsdl11Definition;
    }

    @Bean
    public XsdSchema sucursalesSchema() {
        return new SimpleXsdSchema(new ClassPathResource("sucursales.xsd"));
    }


    // ---------- Productos ----------
    @Bean(name = "productos")
    public DefaultWsdl11Definition productosWsdl(XsdSchema productosSchema) {
        DefaultWsdl11Definition wsdl11Definition = new DefaultWsdl11Definition();
        wsdl11Definition.setPortTypeName("ProductosPort");
        wsdl11Definition.setLocationUri("/ws");
        wsdl11Definition.setTargetNamespace("http://services.super3.das.ubp.edu.ar/");
        wsdl11Definition.setSchema(productosSchema);
        wsdl11Definition.setCreateSoap12Binding(true);
        return wsdl11Definition;
    }

    @Bean
    public XsdSchema productosSchema() {
        return new SimpleXsdSchema(new ClassPathResource("productos.xsd"));
    }
}