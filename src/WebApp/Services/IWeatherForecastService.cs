﻿namespace WebApp.Services
{
    public interface IWeatherForecastService
    {
        IEnumerable<WeatherForecast> Get();
    }
}
