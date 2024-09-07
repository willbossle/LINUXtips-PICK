FROM willbossle/giropops-senhas:2.0

ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

ENV REDIS_HOST=redis

EXPOSE 5000

# WORKDIR /app

# COPY --from=build /home/nonroot/.local/lib/python3.12/site-packages /home/nonroot/.local/lib/python3.12/site-packages
# COPY --from=build /app /app

# HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 CMD python /app/healthcheck.py || exit 1

ENTRYPOINT ["python", "-m", "flask", "run", "--host=0.0.0.0"]
