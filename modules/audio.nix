# Sound via PipeWire (also handles PulseAudio apps).
{
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
}
