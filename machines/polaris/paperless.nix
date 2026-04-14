{ ... }:
{
  services.paperless = {
    enable = true;
    dataDir = "/chonky/paperless";
    settings = {
      # Engling + Dutch
      PAPERLESS_OCR_LANGUAGE = "eng+nld";
    };
  };
}
